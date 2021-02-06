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

        const useSendToDevice = false;

        if (!useSendToDevice) {
          console.log("Sending filtered notification with sendMulticast");

          payload.tokens = adminFIRTokens; //Needed for sendMulticast
          return admin
            .messaging()
            .sendMulticast(payload)
            .then(function (response) {
              console.log(
                "Sent filtered message (using sendMulticast) notification: ",
                response
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
          console.log("Sending filtered message with sendToDevice");
          return admin
            .messaging()
            .sendToDevice(adminFIRTokens, payload)
            .then(function (response) {
              console.log(
                "Sent filtered message with (using sendToDevice) notification: ",
                response
              );
              return true;
            });
        }
      } else {
        const useSendToTopic = false;
        if (!useSendToTopic) {
          console.log("Sending topic message with send");
          payload.topic = topicName;
          return admin
            .messaging()
            .send(payload)
            .then(function (response) {
              console.log(
                "Sent topic message (using send) notification: ",
                response
              );
              return true;
            });
        } else {
          console.log("Sending topic message with sendToTopic");
          return admin
            .messaging()
            .sendToTopic(topicName, payload)
            .then(function (response) {
              console.log(
                "Sent topic message (using sendToTopic) notification: ",
                response
              );
              return true;
            });
        }
      }
    } catch (error) {
      console.log("Notification sent failed:", error);
      return false;
    }
  });

/*
    const optionalUserProfileUrl = message.profilePictureUrl || undefined;

    console.log("Optional User Profile: ", optionalUserProfileUrl);

    const userProfileUrl =
      optionalUserProfileUrl === undefined
        ? undefined
        : optionalUserProfileUrl.substring(
            9,
            optionalUserProfileUrl.length - 1
          );

    console.log("Profile URL: ", userProfileUrl);
    */

/*
    var apnsPayload = {
      payload: {
        aps: {
          "mutable-content": 1,
        },
      },
      fcm_options: {
        image: undefined,
      },
    };

    console.log("Is url defined? ", !(userProfileUrl === undefined));

    if (!(userProfileUrl === undefined)) {
      payload.notification.image = userProfileUrl;
      //   apnsPayload.fcm_options.image = userProfileUrl;
      //   payload.apns = apnsPayload;
    }

    console.log("Payload Body: ", payload);
    */
