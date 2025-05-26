const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendProposalNotification = functions.firestore
    .document("jobs/{jobId}/proposals/{proposalId}")
    .onCreate(async (snap, context) => {
      const proposalData = snap.data();
      const jobId = context.params.jobId;

      const jobDoc = await admin.firestore()
          .collection("jobs").doc(jobId).get();
      const clientId = jobDoc.data().client;

      const clientDoc = await admin.firestore()
          .collection("users").doc(clientId).get();
      const token = clientDoc.data().fcmToken;

      if (!token) return null;

      const payload = {
        notification: {
          title: "New Job Proposal",
          body: `${proposalData.applicantName} applied
          for ${jobDoc.data().title}`,
        },
        token: token,
      };

      return admin.messaging().send(payload);
    });

