import { Request, Response, NextFunction, RequestHandler } from "express";
import { supabase } from "../config/supabaseClient";

export const verifyAdmin: RequestHandler = async (
    req: Request,
    res: Response,
    next: NextFunction,
) => {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
        res.status(401).json({ error: "No token provided" });
        return;
    }

    const token = authHeader.replace("Bearer ", "");

    /** Supabase JWT 검증 */
    const {
        data: { user },
        error,
    } = await supabase.auth.getUser(token);

    if (error || !user) {
        res.status(403).json({ error: "Invalid or expired token" });
        return;
    }

    /**
     * 단일 관리자 이메일 제한 (임시)
     * 추후에는 DB의 'admins' 테이블을 조회하여 권한 레벨을 체크하는 것이 좋습니다.
     */
    console.log(
        `[Auth] Verifying user: ${user.email}, Required: ${process.env.ADMIN_EMAIL}`,
    );

    /**
     * Development Mode: Allow any authenticated user.
     * In production, enable strict role checking or email validation.
     */
    if (user.email !== process.env.ADMIN_EMAIL) {
        console.warn(
            `[Auth] Unauthorized access attempt by: ${user.email} (Expected: ${process.env.ADMIN_EMAIL})`,
        );
        res.status(403).json({ error: "Not authorized as Admin" });
        return;
    }

    // Attach user to request object (Standard Express practice)
    (req as any).user = user;
    next();
};
