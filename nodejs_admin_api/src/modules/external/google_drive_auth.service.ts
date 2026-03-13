import { google } from "googleapis";
import dotenv from "dotenv";

dotenv.config();

/**
 * Service to handle Google Drive authentication.
 * Optimized for Service Account (JWT) and Application Default Credentials (ADC) for production security.
 */
export class GoogleDriveAuthService {
    private auth: any = null;

    constructor() {
        const SERVICE_ACCOUNT_EMAIL = process.env.GOOGLE_SERVICE_ACCOUNT_EMAIL;
        const SERVICE_ACCOUNT_PRIVATE_KEY = process.env.GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY?.replace(/\\n/g, "\n");

        // Legacy OAuth2 credentials (DEPRECATED)
        const CLIENT_ID = process.env.GOOGLE_CLIENT_ID;
        const CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET;
        const REFRESH_TOKEN = process.env.GOOGLE_REFRESH_TOKEN;

        try {
            if (SERVICE_ACCOUNT_EMAIL && SERVICE_ACCOUNT_PRIVATE_KEY) {
                // Priority 1: Service Account (JWT) - Standard for backend servers
                this.auth = new google.auth.JWT({
                    email: SERVICE_ACCOUNT_EMAIL,
                    key: SERVICE_ACCOUNT_PRIVATE_KEY,
                    scopes: [
                        "https://www.googleapis.com/auth/drive.readonly",
                        "https://www.googleapis.com/auth/drive.file",
                    ],
                });
                console.log("✅ [Drive Auth] Authenticated using Service Account (JWT)");
            } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
                // Priority 2: Application Default Credentials (ADC) - Best for GCP Production (Cloud Run, etc.)
                // This allows auth without managing key files in environment variables
                this.auth = new google.auth.GoogleAuth({
                    scopes: [
                        "https://www.googleapis.com/auth/drive.readonly",
                        "https://www.googleapis.com/auth/drive.file",
                    ],
                });
                console.log("✅ [Drive Auth] Authenticated using Application Default Credentials (ADC)");
            } else if (CLIENT_ID && CLIENT_SECRET && REFRESH_TOKEN) {
                // Priority 3: OAuth2 Refresh Token (LEGACY / DEPRECATED)
                console.warn("⚠️ [Drive Auth] Using DEPRECATED OAuth2 Refresh Token. Please migrate to Service Account.");
                this.auth = new google.auth.OAuth2(CLIENT_ID, CLIENT_SECRET);
                this.auth.setCredentials({ refresh_token: REFRESH_TOKEN });
            } else {
                console.error("❌ [Drive Auth] CRITICAL: No authentication credentials found. API will fail.");
            }
        } catch (error) {
            console.error("❌ [Drive Auth] Failed to initialize authentication:", error);
        }
    }

    /**
     * Get the authenticated client.
     */
    getAuthClient() {
        return this.auth;
    }

    /**
     * Check if authentication is properly configured.
     */
    isConfigured(): boolean {
        return this.auth !== null;
    }
}

export const googleDriveAuthService = new GoogleDriveAuthService();

