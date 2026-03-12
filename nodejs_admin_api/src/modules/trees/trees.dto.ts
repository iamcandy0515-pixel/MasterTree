export interface TreeImageDto {
    image_type: "leaf" | "bark" | "flower" | "fruit" | "main" | "full";
    image_url: string;
    thumbnail_url?: string; // Thumbnail image URL (mostly Google Drive or WebP)
    hint?: string; // Quiz answer hint
    is_quiz_enabled?: boolean; // Quiz activation toggle (default: true)
}

export interface CreateTreeDto {
    name_kr: string; // 필수 (Korean Name)
    name_en?: string;
    scientific_name?: string;
    category?: string;
    description?: string;
    difficulty?: number; // 1~5

    // 퀴즈 관련 설정
    quiz_distractors: string[]; // 오답 리스트
    is_auto_quiz_enabled: boolean; // 자동 생성 여부

    // 이미지 리스트 (1:N)
    images: TreeImageDto[];
}

export interface TreeResponseDto {
    id: string; // BigInt as String (JS limit)
    name_kr: string;
    name_en?: string;
    scientific_name?: string;
    category?: string; // "침엽수", "활엽수" 등
    description?: string;
    difficulty: number;
    quiz_distractors: string[];
    is_auto_quiz_enabled: boolean;
    created_at: string;

    // Joined Tree Images
    tree_images?: TreeImageDto[];
}
