import './env';
import { supabase } from './config/supabaseClient';

async function seedMappings() {
    console.log('🌱 Seeding Tree Category Mappings (Fixed Types)...');

    const mappings = [
        { original_name: '침엽수,상록수', display_name: '상록침엽수' },
        { original_name: '침엽수, 낙엽수', display_name: '낙엽침엽수' },
        { original_name: '침엽수,낙엽수', display_name: '낙엽침엽수' },
        { original_name: '활엽수, 상록수', display_name: '상록활엽수' },
        { original_name: '활엽수,상록수', display_name: '상록활엽수' },
        { original_name: '활엽수, 낙엽수', display_name: '낙엽활엽수' },
        { original_name: '활엽수,낙엽수', display_name: '낙엽활엽수' }
    ];

    for (const m of mappings) {
        // Use any to bypass version-specific type conflicts in this environment
        const { error } = await (supabase as any)
            .from('tree_category_mapping')
            .upsert(m, { onConflict: 'original_name' });
        
        if (error) {
            console.error(`❌ Failed to upsert [${m.original_name}]:`, error.message);
        } else {
            console.log(`✅ Upserted [${m.original_name}] -> [${m.display_name}]`);
        }
    }

    console.log('✅ Mapping Seeding Completed.');
}

seedMappings();
