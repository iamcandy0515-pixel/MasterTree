import { Request, Response } from "express";
import { AiService } from "./ai.service";

export class AiController {
    static async predictTree(req: Request, res: Response) {
        const result = await AiService.predict(req.body.imageUrl);
        res.json(result);
    }

    static async getComparisonHint(req: Request, res: Response) {
        const { tree1, tree2, tag } = req.body;
        const result = await AiService.getComparisonHint(tree1, tree2, tag);
        res.json(result);
    }
}
