const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Webhook endpoint to receive football updates from API-Sports
exports.footballWebhook = functions.https.onRequest(async (req, res) => {
    // Optional: Add security check for API key in headers if supported by API-Sports webhooks
    // const secret = req.headers['x-apisports-key'];

    const matchData = req.body;

    if (!matchData || !matchData.teams) {
        console.log("No valid match data received");
        return res.status(400).send("No data");
    }

    try {
        const homeTeam = matchData.teams.home.name;
        const awayTeam = matchData.teams.away.name;
        const homeGoals = matchData.goals.home ?? 0;
        const awayGoals = matchData.goals.away ?? 0;
        const score = `${homeGoals} - ${awayGoals}`;

        // Short status: 1H, 2H, FT, etc.
        const status = matchData.fixture.status.short;

        // Build FCM message
        const message = {
            notification: {
                title: "GOAL! ⚽",
                body: `${homeTeam} ${score} ${awayTeam} (${status})`,
            },
            topic: "live_updates", // Send to all users subscribed to this topic
            android: {
                notification: {
                    sound: "default",
                    priority: "high",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
            },
        };

        // Send notification
        await admin.messaging().send(message);
        console.log(`Notification sent for: ${homeTeam} vs ${awayTeam}`);

        return res.status(200).send("Success");
    } catch (error) {
        console.error("Error processing webhook:", error);
        return res.status(500).send(error.toString());
    }
});
