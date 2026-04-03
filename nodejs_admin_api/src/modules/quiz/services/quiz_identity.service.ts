import { quizRepository } from "../quiz.repository";

/**
 * Quiz Identity Service
 * Handles resolution and creation of category and exam entities.
 */
export class QuizIdentityService {
    /**
     * Ensures category exists or creates it.
     */
    async ensureCategory(subject: string) {
        if (!subject) return null;
        const { data } = await quizRepository.findCategoryByName(subject);
        if (data && (data as any).id) return (data as any).id;
        const { data: newCat } = await quizRepository.createCategory(subject);
        return (newCat as any)?.id;
    }

    /**
     * Ensures exam entity exists or creates it.
     */
    async ensureExam(subject: string, year: number, round: number) {
        if (!year || !round) return null;
        const examTitle = `${subject || "Unknown"} ${year}년 ${round}회`;
        const { data } = await quizRepository.findExam(examTitle, year, round);
        if (data && (data as any).id) return (data as any).id;
        const { data: newExam } = await quizRepository.createExam(year, round, examTitle);
        return (newExam as any)?.id;
    }
}

export const quizIdentityService = new QuizIdentityService();
