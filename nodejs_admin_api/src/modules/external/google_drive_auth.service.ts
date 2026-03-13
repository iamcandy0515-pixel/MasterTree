import { google } from "googleapis";
import dotenv from "dotenv";

dotenv.config();

/**
 * Service to handle Google Drive authentication (OAuth2 or Service Account).
 */
export class GoogleDriveAuthService {
    private auth: any = null;

    constructor() {
        const CLIENT_ID = process.env.GOOGLE_CLIENT_ID;
        const CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET;
        const REFRESH_TOKEN = process.env.GOOGLE_REFRESH_TOKEN;

        // Service Account credentials
        const SERVICE_ACCOUNT_EMAIL = process.env.GOOGLE_SERVICE_ACCOUNT_EMAIL;
        const SERVICE_ACCOUNT_PRIVATE_KEY = process.env.GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY?.replace(/\\n/g, "\n");

        if (SERVICE_ACCOUNT_EMAIL && SERVICE_ACCOUNT_PRIVATE_KEY) {
            // Priority 1: Service Account (JWT)
            this.auth = new google.auth.JWT({
                email: SERVICE_ACCOUNT_EMAIL,
                key: SERVICE_ACCOUNT_PRIVATE_KEY,
                scopes: ["https://www.googleapis.com/auth/drive.readonly"]
            });
            console.log("✅ [Drive Auth] Using Service Account");
        } else if (CLIENT_ID && CLIENT_SECRET && REFRESH_TOKEN) {
            // Priority 2: OAuth2 Refresh Token
            this.auth = new google.auth.OAuth2(CLIENT_ID, CLIENT_SECRET);
            this.auth.setCredentials({ refresh_token: REFRESH_TOKEN });
            console.log("✅ [Drive Auth] Using OAuth2 Refresh Token");
        } else {
            console.warn("⚠️ [Drive Auth] No authentication credentials found in .env.");
        }
    }

    /**
     * Get the authenticated client (JWT or OAuth2).
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

