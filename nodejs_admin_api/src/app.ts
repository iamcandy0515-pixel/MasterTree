import express from "express";
import cors from "cors";
import compression from "compression";

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
    "https://mastertree-user-app.vercel.app",
    "https://mastertree-admin-app.vercel.app"
];

app.use(cors({
    origin: true,
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

export default app;
