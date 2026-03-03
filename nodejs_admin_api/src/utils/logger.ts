import { Request, Response } from "express";

const inMemoryLogs: any[] = [];
const MAX_LOGS = 200;

function addLog(type: string, message: string, colorHex: string) {
    const time = new Date().toISOString().replace("T", " ").substring(0, 19);
    inMemoryLogs.unshift({ time, type, msg: message, color: colorHex });
    if (inMemoryLogs.length > MAX_LOGS) inMemoryLogs.pop();
}

export const logStore = {
    getLogs: () => inMemoryLogs,
    clearLogs: () => {
        inMemoryLogs.length = 0;
    },
};

export const logger = {
    info: (message: string, context?: unknown) => {
        addLog("INFO", message, "0xFF3FB950");
        const timestamp = new Date().toISOString();
        console.log(
            `[INFO] [${timestamp}] ${message}`,
            context ? JSON.stringify(context) : "",
        );
    },
    error: (message: string, error?: unknown) => {
        addLog("ERROR", message + (error ? ` - ${error}` : ""), "0xFFF85149");
        const timestamp = new Date().toISOString();
        console.error(`[ERROR] [${timestamp}] ${message}`, error);
    },
    warn: (message: string, context?: unknown) => {
        addLog("WARN", message, "0xFFFF9800");
        const timestamp = new Date().toISOString();
        console.warn(
            `[WARN] [${timestamp}] ${message}`,
            context ? JSON.stringify(context) : "",
        );
    },
    debug: (message: string, context?: unknown) => {
        addLog("DEBUG", message, "0xFF808080");
        if (process.env.NODE_ENV === "development") {
            const timestamp = new Date().toISOString();
            console.debug(
                `[DEBUG] [${timestamp}] ${message}`,
                context ? JSON.stringify(context) : "",
            );
        }
    },
};
