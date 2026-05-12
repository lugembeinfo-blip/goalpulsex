const admin = require("firebase-admin");
const fetch = require("node-fetch");

const serviceAccount = JSON.parse(
  process.env.FIREBASE_SERVICE_ACCOUNT
);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function checkGoals() {
  try {
    const response = await fetch(
      "https://api.football-data.org/v4/matches",
      {
        headers: {
          "X-Auth-Token": process.env.FOOTBALL_API_TOKEN,
        },
      }
    );

    const data = await response.json();

    if (!data.matches) {
      console.log("No matches found");
      return;
    }

    for (const match of data.matches) {
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
    console.error(error);
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

  console.log("Notification sent");
}

checkGoals();