const admin = require("firebase-admin");
const axios = require("axios");

if (!process.env.FIREBASE_SERVICE_ACCOUNT) {
  throw new Error("FIREBASE_SERVICE_ACCOUNT secret is missing");
}

if (!process.env.FOOTBALL_API_TOKEN) {
  throw new Error("FOOTBALL_API_TOKEN secret is missing");
}

const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function checkGoals() {
  try {
    const response = await axios.get(
      "https://api.football-data.org/v4/matches",
      {
        headers: {
          "X-Auth-Token": process.env.FOOTBALL_API_TOKEN,
        },
      }
    );

    const matches = response.data.matches || [];

    if (matches.length === 0) {
      console.log("No matches found");
      return;
    }

    for (const match of matches) {
      const homeGoals = match.score.fullTime.home ?? 0;
      const awayGoals = match.score.fullTime.away ?? 0;
      const totalGoals = homeGoals + awayGoals;

      if (totalGoals >= 3) {
        await sendNotification(
          "🔥 Goal Alert",
          `${match.homeTeam.name} ${homeGoals} - ${awayGoals} ${match.awayTeam.name}`
        );
      }
    }

    console.log("Goal check completed");
  } catch (error) {
    console.error("Goal checker error:", error.response?.data || error.message);
    process.exit(1);
  }
}

async function sendNotification(title, body) {
  const message = {
    notification: {
      title,
      body,
    },
    topic: "goal_alerts",
  };

  await admin.messaging().send(message);
  console.log("Notification sent:", body);
}

checkGoals();