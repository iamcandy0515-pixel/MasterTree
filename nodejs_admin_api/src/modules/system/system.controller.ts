import { Request, Response } from "express";
import { exec } from "child_process";

export class SystemController {
    static async restartAdmin(req: Request, res: Response) {
        try {
            console.log("🔄 Initiating Admin API restart...");
            res.json({ message: "Admin API is restarting..." }); // Send response first

            // Wait briefly to allow response to send, then exit so nodemon restarts
            setTimeout(() => {
                console.log("🛑 Exiting process to trigger restart.");
                process.exit(1);
            }, 1000);
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async restartUser(req: Request, res: Response) {
        try {
            console.log(
                "⚠️ User server restart requested but not fully supported in local dev via API.",
            );
            res.json({
                message:
                    "User App Server restart is not supported in this environment. Please restart manually.",
            });
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async getLogs(req: Request, res: Response) {
        const { logStore } = require("../../utils/logger");
        res.json({ success: true, data: logStore.getLogs() });
    }

    static async clearLogs(req: Request, res: Response) {
        const { logStore } = require("../../utils/logger");
        logStore.clearLogs();
        res.json({ success: true, message: "Logs cleared" });
    }
}
