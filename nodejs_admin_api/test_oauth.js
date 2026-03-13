
const { google } = require('googleapis');
require('dotenv').config({path: './.env'});

async function test() {
    const auth = new google.auth.OAuth2(
        process.env.GOOGLE_CLIENT_ID,
        process.env.GOOGLE_CLIENT_SECRET
    );
    auth.setCredentials({ refresh_token: process.env.GOOGLE_REFRESH_TOKEN });
    const drive = google.drive({ version: 'v3', auth });
    
    const response = await drive.files.list({
        pageSize: 5,
        fields: 'files(id, name)'
    });
    
    console.log('Top 5 files for this user:');
    response.data.files.forEach(f => {
        console.log(`- ${f.name} (${f.id})`);
    });
}

test().catch(console.error);
