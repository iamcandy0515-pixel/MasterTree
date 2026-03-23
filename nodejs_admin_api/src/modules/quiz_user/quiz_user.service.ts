import { quizSessionService } from "./services/quiz_session.service";
import { quizAttemptService } from "./services/quiz_attempt.service";
import { quizStatService } from "./services/quiz_stat.service";

/**
 * Main service for User Quiz operations.
 * (Refactored to delegate logic to domain-specific services)
 */
export class QuizUserService {
    /**
     * Start a new quiz session and fetch randomized or weakness-targeted questions.
     */
    async generateSession(userId: string, mode: string = "normal", limit: number = 10) {
        return quizSessionService.generateSession(userId, mode, limit);
    }

    /**
     * Submit user answers and update session stats.
     */
    async submitAttempts(userId: string, sessionId: number, attempts: any[]) {
        return quizAttemptService.submitAttempts(userId, sessionId, attempts);
    }

    /**
     * Save a batch of attempts (Sync)
     */
    async saveBatchAttempts(userId: string, attempts: any[]) {
        return quizAttemptService.saveBatchAttempts(userId, attempts);
    }

    /**
     * Get aggregated lightweight stats for User Dashboard
     */
    async getAggregatedStats(userId: string) {
        return quizStatService.getAggregatedStats(userId);
    }
}

export const quizUserService = new QuizUserService();
