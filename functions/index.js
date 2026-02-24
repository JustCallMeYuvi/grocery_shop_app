const { setGlobalOptions } = require("firebase-functions");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

setGlobalOptions({ maxInstances: 10 });

exports.sendDeliveryNotification = onDocumentUpdated(
  "orders/{orderId}",
  async (event) => {

    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    // 🔥 Trigger only when status becomes Delivered
    if (
      beforeData.status !== "Delivered" &&
      afterData.status === "Delivered"
    ) {
      const userId = afterData.userId;

      if (!userId) {
        logger.log("No userId found in order");
        return;
      }

      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(userId)
        .get();

      const token = userDoc.data()?.fcmToken;

      if (!token) {
        logger.log("No FCM token found for user");
        return;
      }

      const message = {
        token: token,
        notification: {
          title: "Order Delivered 🎉",
          body: "Your order has been delivered successfully.",
        },
      };

      await admin.messaging().send(message);

      logger.log("Notification sent successfully");
    }
  }
);