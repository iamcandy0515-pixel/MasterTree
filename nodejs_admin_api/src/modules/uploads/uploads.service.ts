import { supabase } from "../../config/supabaseClient";
import sharp from "sharp";

export class UploadService {
    /**
     * Supabase Storage 업로드 (버킷 지정 가능)
     * 리사이징 및 최적화 기능 포함
     */
    static async uploadToStorage(
        file: Express.Multer.File,
        bucket: string = "tree-images",
        folder: string = "trees",
        options: { maxWidth?: number; quality?: number } = {
            maxWidth: 1024,
            quality: 80,
        },
    ) {
        let buffer = file.buffer;
        let mimetype = file.mimetype;
        let originalName = file.originalname;

        // 이미지 파일인 경우 리사이징 및 최적화 진행
        if (file.mimetype.startsWith("image/")) {
            try {
                const image = sharp(file.buffer);
                const metadata = await image.metadata();

                // 너무 큰 이미지는 에러 반환 (예: 10MB 이상 또는 해상도가 비정상적으로 높음)
                if (
                    file.size > 10 * 1024 * 1024 ||
                    (metadata.width && metadata.width > 8000)
                ) {
                    throw new Error(
                        "이미지 크기를 1024px 이하로 조정해서 올려주세요.",
                    );
                }

                // 리사이징 및 WebP 변환 (용량 절감)
                buffer = await image
                    .resize({
                        width: options.maxWidth,
                        withoutEnlargement: true,
                    })
                    .webp({ quality: options.quality })
                    .toBuffer();

                mimetype = "image/webp";
                originalName = originalName.replace(/\.[^/.]+$/, "") + ".webp";
            } catch (err: any) {
                // 특정 에러 메시지는 그대로 전달, 그 외는 일반 에러
                if (err.message.includes("조정해서")) throw err;
                console.error("Image optimization failed:", err);
                // 최적화 실패 시 원본 사용 시도 (단, 너무 크면 위에서 차단됨)
            }
        }

        const safeName = originalName.replace(/[^a-zA-Z0-9.\-_]/g, "").substring(0, 50);
        const fileName = `${folder}/${Date.now()}_${Math.random()
            .toString(36)
            .substring(7)}_${safeName || "image.webp"}`;

        /** Storage 업로드 */
        const { data, error } = await supabase.storage
            .from(bucket)
            .upload(fileName, buffer, {
                contentType: mimetype,
                upsert: true,
            });

        if (error) throw error;

        /** Public URL 생성 */
        const { data: urlData } = supabase.storage
            .from(bucket)
            .getPublicUrl(fileName);

        return {
            path: data.path,
            publicUrl: urlData.publicUrl,
            size: buffer.length,
            mimetype: mimetype,
        };
    }

    /**
     * Supabase Storage 파일 삭제
     */
    static async deleteFromStorage(
        paths: string[],
        bucket: string = "tree-images",
    ) {
        if (!paths || paths.length === 0) return;

        const { data, error } = await supabase.storage
            .from(bucket)
            .remove(paths);

        if (error) {
            console.error(`[Storage Delete Error]`, error);
            throw error;
        }

        return data;
    }
}
