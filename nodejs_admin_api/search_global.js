
const { google } = require('googleapis');
require('dotenv').config({path: './.env'});

async function search() {
    const auth = new google.auth.OAuth2(
        process.env.GOOGLE_CLIENT_ID,
        process.env.GOOGLE_CLIENT_SECRET
    );
    auth.setCredentials({ refresh_token: process.env.GOOGLE_REFRESH_TOKEN });
    const drive = google.drive({ version: 'v3', auth });
    
    const fileName = "산림필답_2022_2";
    console.log('Searching globally for:', fileName);
    
    const response = await drive.files.list({
        q: `name contains '${fileName}' and trashed = false`,
        fields: 'files(id, name, parents)',
    });
    
    console.log('Found', response.data.files.length, 'files');
    response.data.files.forEach(f => {
        console.log(`- ${f.name} (ID: ${f.id}, Parents: ${JSON.stringify(f.parents)})`);
    });
}

search().catch(console.error);
