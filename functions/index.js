const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Fixed message delivery confirmation
exports.confirmMessageDelivery = functions.https.onCall(async (data, context) => {
  try {
    // Safe logging without circular references
    console.log("Function called, data type:", typeof data);

    // Safely log data without circular references
    const safeData = {};
    if (data && typeof data === "object") {
      Object.keys(data).forEach((key) => {
        try {
          // Only log simple values
          if (typeof data[key] !== "object" || data[key] === null) {
            safeData[key] = data[key];
          } else {
            safeData[key] = "[object]";
          }
        } catch (e) {
          safeData[key] = "[unparseable]";
        }
      });
    }
    console.log("Raw data:", safeData);

    if (!data) {
      console.error("No data received");
      return {
        success: false,
        error: "No data received in function call",
      };
    }

    // Log only the keys and simple values
    console.log("Data keys:", Object.keys(data));

    // Extract parameters with better handling for different data types
    let senderId; let receiverId; let messageTimestamp;

    // Try different ways to access the data
  // Try different ways to access the data
  if (data && typeof data === "object") {
    senderId = data.senderId || data["senderId"] ||
               (data.data && (data.data.senderId || data.data["senderId"]));

    receiverId = data.receiverId || data["receiverId"] ||
                 (data.data && (data.data.receiverId || data.data["receiverId"]));

    messageTimestamp = data.messageTimestamp || data["messageTimestamp"] ||
                       (data.data && (data.data.messageTimestamp || data.data["messageTimestamp"]));
  }

    // IMPROVED: Handle both string and number inputs more safely
    if (senderId !== undefined && senderId !== null) {
      senderId = String(senderId).trim();
    }
    if (receiverId !== undefined && receiverId !== null) {
      receiverId = String(receiverId).trim();
    }
    if (messageTimestamp !== undefined && messageTimestamp !== null) {
      messageTimestamp = String(messageTimestamp).trim();
    }

    console.log("Processed parameters:", {
      senderId: senderId || "missing",
      receiverId: receiverId || "missing",
      messageTimestamp: messageTimestamp || "missing",
      senderIdType: typeof senderId,
      receiverIdType: typeof receiverId,
      timestampType: typeof messageTimestamp,
      rawDataKeys: data ? Object.keys(data) : "no data",
      dataType: typeof data,
    });

    // Validate parameters
    if (!senderId || !receiverId || !messageTimestamp ||
        senderId === "" || receiverId === "" || messageTimestamp === "") {
      const missing = [];
      if (!senderId || senderId === "") missing.push("senderId");
      if (!receiverId || receiverId === "") missing.push("receiverId");
      if (!messageTimestamp || messageTimestamp === "") missing.push("messageTimestamp");

      console.error("Missing or empty parameters:", missing.join(", "));

      return {
        success: false,
        error: `Missing required parameters: ${missing.join(", ")}`,
        debug: {
          receivedTypes: {
            senderId: typeof data.senderId,
            receiverId: typeof data.receiverId,
            messageTimestamp: typeof data.messageTimestamp,
          },
          originalValues: {
            senderId: data.senderId,
            receiverId: data.receiverId,
            messageTimestamp: data.messageTimestamp,
          },
        },
      };
    }

    // Generate conversation ID (same logic as Flutter)
    const conversationId = senderId.localeCompare(receiverId) <= 0 ?
      `${senderId}_${receiverId}` :
      `${receiverId}_${senderId}`;

    console.log(`Looking for message in conversation: ${conversationId}`);
    console.log(`Message timestamp: ${messageTimestamp}`);

    // Try to find the message by exact timestamp
    let messageRef = admin.firestore()
      .collection("Hamid_chats")
      .doc(conversationId)
      .collection("messages")
      .doc(messageTimestamp);

    let messageDoc = await messageRef.get();

    // If not found, wait and retry (message might not be written yet)
    if (!messageDoc.exists) {
      console.log("Message not found, waiting 2 seconds and retrying...");
      await new Promise((resolve) => setTimeout(resolve, 2000));
      messageDoc = await messageRef.get();
    }

    // If still not found, search recent messages
    if (!messageDoc.exists) {
      console.log("Message still not found, searching recent messages...");

      const targetTimestamp = parseInt(messageTimestamp);
      const messages = await admin.firestore()
        .collection("Hamid_chats")
        .doc(conversationId)
        .collection("messages")
        .orderBy("timestamp", "desc")
        .limit(30)
        .get();

      console.log(`Found ${messages.size} recent messages`);

      let foundDoc = null;
      messages.forEach((doc) => {
        if (!foundDoc) {
          const docTimestamp = parseInt(doc.id);
          const timeDiff = Math.abs(docTimestamp - targetTimestamp);

          if (timeDiff < 5000) { // Within 5 seconds
            const data = doc.data();
            // Verify it's the right message
            if (data.fromId == senderId && data.toId == receiverId) {
              console.log(`Found matching message with time diff: ${timeDiff}ms`);
              foundDoc = doc;
            }
          }
        }
      });

      if (foundDoc) {
        messageDoc = foundDoc;
        messageRef = foundDoc.ref;
      } else {
        console.log("Message not found after searching");
        // Return success anyway - message will be marked when receiver opens chat
        return {
          success: true,
          reason: "Message will be marked as delivered when receiver opens chat",
          conversationId: conversationId,
        };
      }
    }

    const messageData = messageDoc.data();

    // Check if already delivered
    if (messageData.delivered && messageData.delivered !== "" && messageData.delivered !== null) {
      console.log("Message already delivered");
      return {
        success: true,
        reason: "Already delivered",
        deliveredTime: messageData.delivered,
      };
    }

    // Update delivery status
    const deliveredTime = Date.now().toString();
    await messageDoc.ref.update({
      delivered: deliveredTime,
      status: "delivered",
      deliveryPending: false,
    });

    console.log(`Message delivery confirmed at ${deliveredTime}`);

    return {
      success: true,
      deliveredTime: deliveredTime,
      conversationId: conversationId,
    };

  } catch (error) {
    console.error("Error in confirmMessageDelivery:", error.message);
    console.error("Error stack:", error.stack);

    // Return success anyway to prevent retries
    return {
      success: true,
      error: error.message,
      reason: "Error occurred but returning success to prevent retries",
    };
  }
});

// New function to mark all pending messages as delivered when user opens app
exports.markPendingMessagesDelivered = functions.https.onCall(async (data, context) => {
  try {
    const { userId } = data;

    if (!userId) {
      return {
        success: false,
        error: "Missing userId parameter",
      };
    }

    console.log(`Marking pending messages as delivered for user: ${userId}`);

    // Query undelivered messages
    const pendingMessages = await admin.firestore()
      .collectionGroup("messages")
      .where("toId", "==", userId.toString())
      .where("delivered", "==", "")
      .limit(50)
      .get();

    console.log(`Found ${pendingMessages.size} pending messages`);

    if (pendingMessages.empty) {
      return { success: true, count: 0 };
    }

    const batch = admin.firestore().batch();
    const deliveredTime = Date.now().toString();
    let count = 0;

    pendingMessages.forEach((doc) => {
      batch.update(doc.ref, {
        delivered: deliveredTime,
        status: "delivered",
        deliveryPending: false,
      });
      count++;
    });

    await batch.commit();

    console.log(`Successfully marked ${count} messages as delivered`);

    return {
      success: true,
      count: count,
      deliveredTime: deliveredTime,
    };

  } catch (error) {
    console.error("Error in markPendingMessagesDelivered:", error);
    return {
      success: false,
      error: error.message,
    };
  }
});
