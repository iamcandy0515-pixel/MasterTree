import { google } from "googleapis";
import dotenv from "dotenv";

dotenv.config();

const CLIENT_ID = process.env.GOOGLE_CLIENT_ID;
const CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET;
const REFRESH_TOKEN = process.env.GOOGLE_REFRESH_TOKEN;

/**
 * Service to handle Google OAuth2 authentication and token management.
 */
export class GoogleDriveAuthService {
    private auth;

    constructor() {
        if (!CLIENT_ID || !CLIENT_SECRET || !REFRESH_TOKEN) {
            console.warn("⚠️ Google OAuth2 credentials missing in .env.");
            this.auth = null;
            return;
        }

        this.auth = new google.auth.OAuth2(CLIENT_ID, CLIENT_SECRET);
        this.auth.setCredentials({ refresh_token: REFRESH_TOKEN });
    }

    /**
     * Get the authenticated OAuth2 client.
     */
    getAuthClient() {
        return this.auth;
    }

    /**
     * Check if OAuth2 is properly configured.
     */
    isConfigured(): boolean {
        return this.auth !== null;
    }
}

export const googleDriveAuthService = new GoogleDriveAuthService();
