import { cloudinary } from "../../config/cloudinary";
import { Readable } from "stream";

export class UploadService {
    /**
     * Cloudinary 이미지 업로드
     * f_auto, q_auto 최적화 파라미터를 포함한 URL 반환
     */
    static async uploadToStorage(
        file: Express.Multer.File,
        _bucket: string = "tree-images", // 호환성을 위해 유지
        folder: string = "trees",
        options: { maxWidth?: number; quality?: number } = {
            maxWidth: 1024,
            quality: 80,
        },
    ) {
        const buffer = file.buffer;
        const originalName = file.originalname;

        // 파일 크기 제한 (10MB)
        if (file.size > 10 * 1024 * 1024) {
            throw new Error("파일 크기를 10MB 이하로 업로드해주세요.");
        }

        const safeName = originalName.replace(/[^a-zA-Z0-9.\-_]/g, "").substring(0, 50);
        const fileName = `${Date.now()}_${Math.random().toString(36).substring(7)}_${safeName || "image"}`;

        return new Promise<{ publicUrl: string; path: string; size: number; mimetype: string }>((resolve, reject) => {
            const uploadStream = cloudinary.uploader.upload_stream(
                {
                    folder: `tree-images/${folder}`,
                    public_id: fileName,
                    transformation: [
                        { width: options.maxWidth, crop: "limit" },
                        { quality: "auto", fetch_format: "auto" }
                    ],
                },
                (error, result) => {
                    if (error) {
                        console.error("Cloudinary upload failed:", error);
                        return reject(new Error("Cloudinary 업로드에 실패했습니다."));
                    }
                    if (!result) return reject(new Error("업로드 결과값이 없습니다."));

                    // f_auto, q_auto가 포함된 최적화 주소 생성
                    // Cloudinary의 최신 SDK는 원본 URL에 이미 변환 옵션을 적용할 수 있음
                    const optimizedUrl = result.secure_url.replace("/upload/", "/upload/f_auto,q_auto/");

                    resolve({
                        publicUrl: optimizedUrl,
                        path: result.public_id,
                        size: result.bytes,
                        mimetype: `${result.resource_type}/${result.format}`,
                    });
                }
            );

            Readable.from(buffer).pipe(uploadStream);
        });
    }

    /**
     * Cloudinary 파일 삭제
     */
    static async deleteFromStorage(
        publicIds: string[],
        _bucket: string = "tree-images",
    ) {
        if (!publicIds || publicIds.length === 0) return;

        try {
            const results = await Promise.all(
                publicIds.map(id => cloudinary.uploader.destroy(id))
            );
            return results;
        } catch (error) {
            console.error(`[Cloudinary Delete Error]`, error);
            throw error;
        }
    }
}
