import * as dotenv from 'dotenv';
dotenv.config();
import { supabase } from "./src/config/supabaseClient";

async function analyzeTreeImages() {
  const { data, count, error } = await supabase
    .from('tree_images')
    .select('id, tree_id, image_type, image_url, hint, is_quiz_enabled', { count: 'exact' });

  if (error) {
    console.error('Error:', error);
    return;
  }

  console.log(`Total images: ${count}`);
  const quizEnabled = data.filter(img => img.is_quiz_enabled);
  console.log(`Quiz enabled images: ${quizEnabled.length}`);
  
  const driveLinks = data.filter(img => img.image_url?.includes('drive.google.com'));
  console.log(`Drive links: ${driveLinks.length}`);
  
  const brokenLinks = data.filter(img => !img.image_url);
  console.log(`Missing URLs: ${brokenLinks.length}`);
  
  console.log('\nSample Quiz Enabled Data:');
  quizEnabled.slice(0, 5).forEach(img => {
    console.log(`- Tree ${img.tree_id} (${img.image_type}): ${img.image_url}`);
  });
}

analyzeTreeImages();
