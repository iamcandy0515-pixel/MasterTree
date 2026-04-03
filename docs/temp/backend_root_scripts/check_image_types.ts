import { supabase } from './src/config/supabaseClient';

async function run() {
    try {
        const { data, error } = await supabase
            .from('tree_images')
            .select('image_type')
            .limit(50);
        
        if (error) {
            console.error('Supabase Error:', error);
            return;
        }

        const counts: Record<string, number> = {};
        data?.forEach(img => {
            const type = img.image_type;
            counts[type] = (counts[type] || 0) + 1;
        });
        
        console.log('Image Type Counts:', counts);
    } catch (e) {
        console.error('Catch Error:', e);
    }
}

run();
