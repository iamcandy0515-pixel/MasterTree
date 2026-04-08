import "dotenv/config";
import { supabase } from './src/config/supabaseClient';

async function diagnose() {
    console.log('--- 🔍 서비스 데이터 진단 시작 ---');
    try {
        // 1. 트리 이미지 타입 샘플링
        const { data: images, error: imgError } = await supabase
            .from('tree_images')
            .select(`
                id,
                image_type,
                image_url,
                trees(id, name_kr)
            `)
            .limit(10);
        
        if (imgError) throw imgError;
        
        console.log('1. DB 이미지 타입 및 URL 샘플:');
        images?.forEach(img => {
            console.log(`- [${img.trees?.name_kr}] 타입: ${img.image_type}, URL: ${img.image_url?.substring(0, 30)}...`);
        });

        // 2. 이미지 타입 목록 확인
        const { data: types } = await supabase
            .from('tree_images')
            .select('image_type');
        const uniqueTypes = [...new Set(types?.map(t => t.image_type))];
        console.log('2. DB의 고유 이미지 타입들:', uniqueTypes);

        // 3. 비교 수목 그룹 샘플 확인
        const { data: groups, error: grpError } = await supabase
            .from('tree_groups')
            .select(`
                id,
                group_name,
                tree_group_members (
                    id,
                    trees (
                        id,
                        name_kr,
                        tree_images (id, image_type, image_url)
                    )
                )
            `)
            .limit(1);

        if (grpError) throw grpError;

        if (groups && groups.length > 0) {
            console.log('3. 비교 그룹 데이터 구조 확인:');
            const group = groups[0];
            console.log(`- 그룹명: ${group.group_name}`);
            group.tree_group_members.forEach((m: any) => {
                console.log(`  - 수목: ${m.trees.name_kr}`);
                m.trees.tree_images.forEach((img: any) => {
                    console.log(`    - [${img.image_type}] 이미지 경로 존재`);
                });
            });
        }
    } catch (e: any) {
        console.error('진단 중 오류 발생:', e.message);
    }
}

diagnose();
