const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);

const getUserNameFromEmail = (email) => {
  const emailParts = email.split("@");
  var userName =
    emailParts.length === 2 ? emailParts[0].split(".").join("") : "";
  return userName;
};

exports.sendSpeechDrillDiscussionsMessageNotification = functions.database
  .ref("/discussionMessages/{autoId}/")
  .onCreate(async (snapshot, context) => {
    // console.log("Snapshot: ", snapshot);

    try {
      const groupsRef = admin.database().ref("people/groups");
      const adminUsersRef = groupsRef.child("admin");
      const filteredUsersRef = groupsRef.child("filtered");
      const filteredUsersSnapshot = await filteredUsersRef.once("value");
      const adminUsersSnapshot = await adminUsersRef.once("value");
      var adminUsersFIRTokens = {};
      var filteredUsersFIRTokens = {};

      if (filteredUsersSnapshot.exists()) {
        filteredUsersFIRTokens = filteredUsersSnapshot.val();
      }
      if (adminUsersSnapshot.exists()) {
        adminUsersFIRTokens = adminUsersSnapshot.val();
      }

      // console.log(
      //   "Admin and Filtered Users: ",
      //   adminUsersFIRTokens,
      //   " ",
      //   filteredUsersFIRTokens
      // );

      const topicName = "SpeechDrillDiscussions";
      const message = snapshot.val();

      // console.log("Received new message: ", message);

      const senderName = message.userName;
      const senderCountry = message.userCountryEmoji;
      const title = senderName + " " + senderCountry;
      const messageText = message.message;
      const messageTimestamp = message.messageTimestamp.toString();
      const messageID = message.hasOwnProperty("messageID")
        ? message.messageID
        : undefined;
      const senderEmailId = message.userEmailAddress;
      const senderUserName = getUserNameFromEmail(senderEmailId);

      const isSenderFiltered = filteredUsersFIRTokens.hasOwnProperty(
        senderUserName
      );

      console.log(
        "Will attempt to send notification for message with message id: ",
        messageID
      );

      var payload = {
        notification: {
          title: title,
          body: messageText,
        },
        data: {
          messageID: messageID,
          messageTimestamp: messageTimestamp,
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
            },
          },
        },
      };
      console.log("Is sender filtered? ", isSenderFiltered);

      if (isSenderFiltered) {
        adminFIRTokens = Object.values(adminUsersFIRTokens);
        console.log("Sending filtered notification with sendMulticast()");
        payload.tokens = adminFIRTokens; //Needed for sendMulticast
        return admin
          .messaging()
          .sendMulticast(payload)
          .then((response) => {
            console.log(
              "Sent filtered message (using sendMulticast) notification: ",
              JSON.stringify(response)
            );
            if (response.failureCount > 0) {
              const failedTokens = [];
              response.responses.forEach((resp, idx) => {
                if (!resp.success) {
                  failedTokens.push(adminFIRTokens[idx]);
                }
              });
              console.log(
                "List of tokens that caused failures: " + failedTokens
              );
            }
            return true;
          });
      } else {
        console.log("Sending topic message with send()");
        payload.topic = topicName;
        return admin
          .messaging()
          .send(payload)
          .then((response) => {
            console.log(
              "Sent topic message (using send) notification: ",
              JSON.stringify(response)
            );
            return true;
          });
      }
    } catch (error) {
      console.log("Notification sent failed:", error);
      return false;
    }
  });
