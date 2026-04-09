import express from "express";
import cors from "cors";
import compression from "compression";
import path from "path";

import treeRoutes from "./modules/trees/trees.routes";
import treeRegistrationRoutes from "./modules/tree-registration/tree-registration.routes";
import uploadRoutes from "./modules/uploads/uploads.routes";
import aiRoutes from "./modules/ai/ai.routes";
import { userRoutes } from "./modules/users";
import statsRoutes from "./modules/stats/stats.routes";
import quizRoutes from "./modules/quiz/quiz.routes";
import treeGroupRoutes from "./modules/tree-groups/tree-groups.routes";
import settingsRoutes from "./modules/settings/settings.routes";
import quizUserRoutes from "./modules/quiz_user/quiz_user.routes";
import externalRoutes from "./modules/external/external.routes";
import systemRoutes from "./modules/system/system.routes";

const app = express();

const allowedOrigins = [
    "http://localhost:5050",
    "http://localhost:4000",
    "http://localhost:5000",
    "http://localhost:5001",
    "http://localhost:8081",
    "http://localhost:3000",
    "http://127.0.0.1:5050",
    "http://127.0.0.1:4000",
    "http://127.0.0.1:5000",
    "http://127.0.0.1:5001",
    "http://127.0.0.1:8081",
    "https://mastertree-user.vercel.app",
    "https://mastertree-admin.vercel.app",
    "https://mastertree-api.vercel.app"
];

app.use(cors({
    origin: (origin, callback) => {
        // [1] 만약 Origin이 명시되지 않은 경우(예: 서버 대 서버 통신) 허용
        if (!origin) return callback(null, true);

        // [2] 화이트리스트에 포함되어 있거나, 개발 중인 로컬호스트인 경우 허용
        const isAllowed = allowedOrigins.includes(origin) || origin.includes('localhost') || origin.includes('127.0.0.1');

        if (isAllowed) {
            callback(null, true);
        } else {
            console.error(`🚨 [CORS] Blocked request from unauthorized origin: ${origin}`);
            callback(new Error("CORS Policy Violation: Origin not allowed"));
        }
    },
    credentials: true,
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
    allowedHeaders: ["Content-Type", "Authorization", "X-Requested-With", "Accept"]
}));
app.use(compression() as any);
app.use(express.json());

// Debug logging middleware
app.use((req, res, next) => {
    console.log(`[REQ] ${new Date().toISOString()} ${req.method} ${req.url}`);
    next();
});

/** Feature Routes */
app.use("/api/trees", treeRoutes);
app.use("/api/tree-registration", treeRegistrationRoutes);
app.use("/api/uploads", uploadRoutes);
app.use("/api/ai", aiRoutes);
app.use("/api/users", userRoutes); // Login & Auth
app.use("/api/stats", statsRoutes); // Dashboard Stats
app.use("/api/quiz", quizRoutes); // Quiz Management
app.use("/api/user-quiz", quizUserRoutes); // User Quiz Solving & Stats
app.use("/api/tree-groups", treeGroupRoutes); // Lookalike Tree Groups
app.use("/api/settings", settingsRoutes); // System Settings (Entry Code)
app.use("/api/external", externalRoutes);
app.use("/api/system", systemRoutes);

/** Static Frontend Serving (Unified Monorepo) */
const publicPath = path.resolve(__dirname, "../public");

// 1. [ADMIN] Serve admin app at /admin
app.use("/admin", express.static(path.join(publicPath, "admin"), { index: "index.html" }));
app.get("/admin*", (req, res) => {
    res.sendFile(path.join(publicPath, "admin", "index.html"));
});

// 2. [USER] Serve user app at root (/)
// API가 아닌 모든 다른 경로는 사용자 앱으로 보냄
app.use("/", express.static(path.join(publicPath, "user"), { index: "index.html" }));
app.get("*", (req, res) => {
    // API 경로는 여기서 처리하지 않음 (이미 위에서 처리됨)
    if (req.url.startsWith("/api")) {
        return res.status(404).json({ success: false, message: "API endpoint not found" });
    }
    res.sendFile(path.join(publicPath, "user", "index.html"));
});

export default app;


