import { Request, Response } from "express";
import { TreeService } from "../trees/trees.service";
import { TreeRegistrationDto } from "./tree-registration.dto";
import { successResponse, errorResponse } from "../../utils/response";
import { CreateTreeDto } from "../trees/trees.dto";

export class TreeRegistrationController {
    /**
     * 신규 수목 등록 전용 엔드포인트
     * - habit (상록수/낙엽수)을 difficulty (1, 2)로 매핑
     * - 각 이미지 타입별 단일 이미지 보장 (클라이언트가 이미 처리했을 것이나 서버에서 최종 확인)
     */
    static async register(req: Request, res: Response) {
        try {
            const dto: TreeRegistrationDto = req.body;

            // 1. 필수 값 검증
            if (!dto.name_kr) {
                return errorResponse(res, "수목명(name_kr)은 필수입니다.", 400);
            }
            if (!dto.images || dto.images.length === 0) {
                return errorResponse(res, "최소 1개 이상의 이미지가 필요합니다.", 400);
            }

            // 2. 성상(Habit) 매핑 -> Difficulty
            const difficultyMap = {
                "상록수": 1,
                "낙엽수": 2
            };
            const difficulty = difficultyMap[dto.habit] || 1;

            // 3. 이미지 타입 중복 체크 (태그별 단 1장)
            const seenTypes = new Set<string>();
            const uniqueImages = dto.images.filter(img => {
                if (seenTypes.has(img.image_type)) return false;
                seenTypes.add(img.image_type);
                return true;
            });

            // 4. 기존 CreateTreeDto 형식으로 변환하여 TreeService 호출
            const createDto: CreateTreeDto = {
                name_kr: dto.name_kr,
                scientific_name: dto.scientific_name,
                category: dto.category,
                description: dto.description,
                difficulty: difficulty,
                quiz_distractors: dto.quiz_distractors.slice(0, 2), // 오답 2개 제한
                is_auto_quiz_enabled: dto.is_auto_quiz_enabled,
                images: uniqueImages
            };

            const userId = (req as any).user?.id;
            if (!userId) {
                return errorResponse(res, "인증 정보가 없습니다.", 401);
            }

            const newTree = await TreeService.create(createDto, userId);
            
            successResponse(res, newTree, "성공적으로 등록되었습니다.", 201);
        } catch (error: any) {
            console.error("[TreeRegistration] Error:", error);
            errorResponse(res, error.message || "등록 중 오류가 발생했습니다.", 500);
        }
    }
}
