const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Enhanced message delivery confirmation
exports.confirmMessageDelivery = functions.https.onCall(async (data, context) => {
  try {
    const { senderId, receiverId, messageTimestamp } = data;

    if (!senderId || !receiverId || !messageTimestamp) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing required parameters",
      );
    }

    const conversationId = senderId.localeCompare(receiverId) <= 0 ?
      `${senderId}_${receiverId}` :
      `${receiverId}_${senderId}`;

    const messageRef = admin.firestore()
      .collection("Hamid_chats")
      .doc(conversationId)
      .collection("messages")
      .doc(messageTimestamp);

    const messageDoc = await messageRef.get();

    if (!messageDoc.exists) {
      return { success: false, reason: "Message not found" };
    }

    const messageData = messageDoc.data();

    // Check if already delivered
    if (messageData.delivered && messageData.delivered !== "") {
      return { success: true, reason: "Already delivered" };
    }

    // Update delivery status
    const deliveredTime = Date.now().toString();
    await messageRef.update({
      delivered: deliveredTime,
      status: "delivered",
      deliveryPending: false,
    });

    return {
      success: true,
      deliveredTime: deliveredTime,
    };

  } catch (error) {
    console.error("Error in confirmMessageDelivery:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});
