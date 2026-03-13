import { TreeImageDto } from "../trees/trees.dto";

export interface TreeRegistrationDto {
    name_kr: string;
    scientific_name?: string;
    category?: string; // "침엽수" | "활엽수"
    description?: string;
    habit: "상록수" | "낙엽수"; // UI에서 받는 값
    
    // 퀴즈 관련 설정 (오답 2개 고정)
    quiz_distractors: string[]; 
    is_auto_quiz_enabled: boolean;

    // 이미지 리스트 (태그별 단 1장씩만 포함되어야 함)
    images: TreeImageDto[];
}
