import { Router } from "express";
import { statsController } from "./stats.controller";
import { verifyAdmin } from "../../middleware/verifyAdmin";
import { verifyUser } from "../../middleware/verifyUser";

const router = Router();

// Protected Route: Only Admins can see main dashboard stats
router.get(
    "/",
    verifyAdmin,
    statsController.getDashboardStats.bind(statsController),
);

router.get(
    "/detailed",
    verifyAdmin,
    statsController.getAdminDetailedStats.bind(statsController),
);

// Performance stats (Admin view of a specific user)
router.get(
    "/performance/:userId",
    verifyAdmin,
    statsController.getUserPerformanceStats.bind(statsController),
);

// Public Route: Users can see general dashboard stats
router.get(
    "/user",
    statsController.getUserDashboardStats.bind(statsController),
);

// Personal Route: User can see their own performance stats
router.get(
    "/performance",
    verifyUser,
    statsController.getUserPerformanceStats.bind(statsController),
);

export default router;
