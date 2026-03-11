import axios from "axios";

async function testEndpoint() {
    try {
        const response = await axios.post(
            "http://localhost:4000/api/v1/admin/quiz-manage/extract-batch",
            {
                fileId: "산림필답_2022_3",
                startNumber: 1,
                endNumber: 5,
                subject: "Test",
                year: 2022,
                round: 3,
            },
        );
        console.log("Response Status:", response.status);
        console.log("Response Data:", JSON.stringify(response.data, null, 2));
    } catch (error: any) {
        if (error.response) {
            console.log("Error Status:", error.response.status);
            console.log(
                "Error Data:",
                JSON.stringify(error.response.data, null, 2),
            );
        } else {
            console.log("Error Message:", error.message);
        }
    }
}

testEndpoint();
