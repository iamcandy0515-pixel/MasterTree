const { createClient } = require('@supabase/supabase-js');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '.env') });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

async function diagnose() {
    console.log('--- 🔍 서비스 데이터 진단 시작 (박달나무/자작나무) ---');
    try {
        const treeIds = [14, 15]; // 자작나무(14?), 박달나무(15)
        const { data: members } = await supabase
            .from('tree_group_members')
            .select('group_id, trees(name_kr)')
            .in('tree_id', treeIds);
            
        console.log('\n🔍 박달나무/자작나무 포함 그룹 검색 결과:');
        members.forEach(m => console.log(`- 수목: ${m.trees.name_kr}, Group ID: ${m.group_id}`));
        
        if (members.length > 0) {
            const groupId = members[0].group_id;
            const { data: fullGroup } = await supabase
                .from('tree_groups')
                .select('*, tree_group_members(*, trees(*, tree_images(*)))')
                .eq('id', groupId)
                .single();
            
            console.log(`\n📦 확인된 그룹: ${fullGroup.group_name}`);
            fullGroup.tree_group_members.forEach(m => {
                console.log(`  🌳 ${m.trees.name_kr} 이미지 정보:`);
                m.trees.tree_images.forEach(img => {
                    console.log(`     📸 [${img.image_type}] ${img.image_url?.substring(0, 50)}`);
                });
            });
        }

    } catch (e) {
        console.error('진단 중 오류:', e.message);
    }
}

diagnose();
