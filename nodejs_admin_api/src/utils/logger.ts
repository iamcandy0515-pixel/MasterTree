/**
 * Centralized Logger Utility
 * Controls output based on NODE_ENV (development vs production)
 */

const isDev = process.env.NODE_ENV !== 'production';

export const logger = {
    info: (message: string, ...args: any[]) => {
        if (isDev) {
            console.log(`[INFO] ${message}`, ...args);
        }
    },
    error: (message: string, error?: any) => {
        // Errors are usually logged even in production for monitoring, 
        // but we can sanitize them if needed.
        console.error(`[ERROR] ${message}`, error || '');
    },
    debug: (message: string, ...args: any[]) => {
        if (isDev) {
            console.debug(`[DEBUG] ${message}`, ...args);
        }
    },
    warn: (message: string, ...args: any[]) => {
        if (isDev) {
            console.warn(`[WARN] ${message}`, ...args);
        }
    }
};

/**
 * [Advanced] Silence global console.log in production
 * To be called in app.ts or index.ts
 */
export const silenceConsoleInProduction = () => {
    if (!isDev) {
        console.log = () => {};
        console.debug = () => {};
        console.warn = () => {};
        // Keep console.error working for critical issues
    }
};
