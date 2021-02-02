const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);

exports.sendSpeechDrillDiscussionsMessageNotification = functions.database
  .ref("/discussionMessages/{autoId}/")
  .onCreate((snapshot, context) => {
    // console.log("Snapshot: ", snapshot);

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

    var payload = {
      notification: {
        title: title,
        body: messageText,
      },
      data: {
        messageID: messageID,
        messageTimestamp: messageTimestamp,
      },
      topic: topicName,
    };

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

    return admin
      .messaging()
      .send(payload)
      .then(function (response) {
        console.log("Notification sent successfully:", response);
        return true;
      })
      .catch(function (error) {
        console.log("Notification sent failed:", error);
      });
  });
