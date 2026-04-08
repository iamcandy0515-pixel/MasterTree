/**
 * Centralized Logger Utility
 * Controls output based on NODE_ENV (development vs production)
 */

const isDev = process.env.NODE_ENV !== 'production';

export const logStore = {
    logs: [] as { timestamp: string, level: string, message: string }[],
    maxLogs: 100,
    add: (level: string, message: string) => {
        logStore.logs.push({ 
            timestamp: new Date().toISOString(), 
            level, 
            message 
        });
        if (logStore.logs.length > logStore.maxLogs) {
            logStore.logs.shift();
        }
    },
    getLogs: () => logStore.logs,
    clearLogs: () => { logStore.logs = []; }
};

export const logger = {
    info: (message: string, ...args: any[]) => {
        logStore.add('INFO', message + (args.length > 0 ? ' ' + JSON.stringify(args) : ''));
        if (isDev) {
            console.log(`[INFO] ${message}`, ...args);
        }
    },
    error: (message: string, error?: any) => {
        const errorMsg = error ? (error.message || JSON.stringify(error)) : '';
        logStore.add('ERROR', `${message} ${errorMsg}`);
        console.error(`[ERROR] ${message}`, error || '');
    },
    debug: (message: string, ...args: any[]) => {
        logStore.add('DEBUG', message + (args.length > 0 ? ' ' + JSON.stringify(args) : ''));
        if (isDev) {
            console.debug(`[DEBUG] ${message}`, ...args);
        }
    },
    warn: (message: string, ...args: any[]) => {
        logStore.add('WARN', message + (args.length > 0 ? ' ' + JSON.stringify(args) : ''));
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
