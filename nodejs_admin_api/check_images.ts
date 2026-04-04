import * as dotenv from 'dotenv';
dotenv.config();
import { supabase } from "./src/config/supabaseClient";

async function checkImages() {
  const { data, error } = await supabase
    .from('tree_images')
    .select('id, tree_id, image_type, image_url, hint')
    .limit(10);

  if (error) {
    console.error('Error fetching images:', error);
    return;
  }

  console.log('Sample images from tree_images table:');
  data?.forEach(img => {
    console.log(`ID: ${img.id}, TreeID: ${img.tree_id}, Type: ${img.image_type}`);
    console.log(`URL: ${img.image_url}`);
    console.log('---');
  });
}

checkImages();
