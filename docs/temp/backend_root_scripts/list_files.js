
const { google } = require('googleapis');
require('dotenv').config({path: './.env'});

async function list() {
    const auth = new google.auth.OAuth2(
        process.env.GOOGLE_CLIENT_ID,
        process.env.GOOGLE_CLIENT_SECRET
    );
    auth.setCredentials({ refresh_token: process.env.GOOGLE_REFRESH_TOKEN });
    const drive = google.drive({ version: 'v3', auth });
    
    const folderId = '1GK_EJ3ZaJ8nzdH1JW7wD_bXn6RH6BxkT';
    console.log('Listing files in folder:', folderId);
    
    const response = await drive.files.list({
        q: `'${folderId}' in parents and trashed = false`,
        fields: 'files(id, name)',
        pageSize: 50
    });
    
    console.log('Found', response.data.files.length, 'files');
    response.data.files.forEach(f => {
        console.log(`- ${f.name} (${f.id})`);
    });
}

list().catch(console.error);
