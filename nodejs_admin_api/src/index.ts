import dotenv from "dotenv";
dotenv.config();

import app from "./app";
import treesRoutes from "./modules/trees/trees.routes";
import externalRoutes from "./modules/external/external.routes"; // Import External routes
import uploadRoutes from "./modules/uploads/uploads.routes";
import systemRoutes from "./modules/system/system.routes";

// Feature Routes are managed in app.ts

const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, () => {
    console.log(`✅ Admin API running on port ${PORT} (reloaded)`);
});

// Increase timeouts to prevent 'Failed to fetch' for long-running AI extraction tasks
server.keepAliveTimeout = 300000; // 5 minutes
server.headersTimeout = 301000; // slightly greater than keepAliveTimeout
server.timeout = 300000;

// Graceful Shutdown to prevent zombie processes
const shutdownGracefully = (signal: string) => {
    console.log(`\nReceived ${signal}. Shutting down gracefully...`);
    server.close(() => {
        console.log("Server closed.");
        process.exit(0);
    });
};

process.on("SIGINT", () => shutdownGracefully("SIGINT"));
process.on("SIGTERM", () => shutdownGracefully("SIGTERM"));
