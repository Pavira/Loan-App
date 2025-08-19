// require("dotenv").config();

// // const functionsV1 = require("firebase-functions/v1"); // ✅ for Firestore
// const { pubsub } = require("firebase-functions/v2");  // ✅ for Scheduler
// const { onDocumentCreated } = require("firebase-functions/v2/firestore");
// const { onSchedule } = require("firebase-functions/v2/scheduler"); // 🔥 Correct scheduler import
// const admin = require("firebase-admin");
// const twilio = require("twilio");

// admin.initializeApp();

// const client = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

// // ✅ Loan Created Trigger (using Firestore from v1)

// exports.onLoanCreated = onDocumentCreated(
//   {
//     document: 'loanDetails/{loanId}',
//     region: 'asia-south1',
//   },
//   async (event) => {
//     const snapshot = event.data;
//     if (!snapshot) {
//       console.log("No document data found.");
//       return;
//     }

//     const data = snapshot.data();

//     const customerId = data.customer_id;
//     const loanAmount = data.loan_amount;
//     const customerName = data.customer_name;

//     if (!customerId || !loanAmount || !customerName) {
//       console.log("Missing required loan data.");
//       return;
//     }

//     // 🔄 Fetch phone number from customerDetails collection
//     try {
//       const customerRef = db.collection("customerDetails").doc(customerId);
//       const customerSnap = await customerRef.get();

//       if (!customerSnap.exists) {
//         console.log(`Customer ${customerId} not found.`);
//         return;
//       }

//       const phone = customerSnap.data().phone_number;
//       if (!phone) {
//         console.log("Phone number missing.");
//         return;
//       }

//       const message = `Hi ${customerName}, your loan of ₹${loanAmount} has been successfully approved.`;

//       // 📤 Send SMS
//       const smsPromise = client.messages.create({
//         body: message,
//         from: process.env.TWILIO_PHONE_NUMBER, // SMS sender number
//         to: phone,
//       });

//       // 📤 Send WhatsApp
//       const whatsappPromise = client.messages.create({
//         body: message,
//         from: 'whatsapp:' + process.env.TWILIO_WHATSAPP_NUMBER, // must be sandbox or approved number
//         to: 'whatsapp:' + phone,
//       });

//       await Promise.all([smsPromise, whatsappPromise]);

//       console.log(`✅ SMS & WhatsApp sent to ${phone}`);
//     } catch (err) {
//       console.error("❌ Error sending messages:", err);
//     }
//   }
// );

// // exports.onLoanCreated = functionsV1
// //   .region('asia-south1')
// //   .firestore
// //   .document('loanDetails/{loanId}')
// //   .onCreate(async (snap, context) => {
// //     const data = snap.data();
// //     if (!data || !data.customer_id || !data.customer_name || !data.loan_amount) {
// //       console.log("Missing required loan data.");
// //       return;
// //     }

// //     const customerId = data.customer_id;

// //     const db = admin.firestore();
// //     try {
// //       const customerDoc = await db.collection('customerDetails').doc(customerId).get();

// //       if (!customerDoc.exists) {
// //         console.log(`Customer not found: ${customerId}`);
// //         return;
// //       }

// //       const customerData = customerDoc.data();
// //       const phoneNumber = customerData.phone_number;

// //       if (!phoneNumber) {
// //         console.log(`No phone number found for customer: ${customerId}`);
// //         return;
// //       }

// //       const message = `Hi ${data.customer_name}, your loan of ₹${data.loan_amount} has been successfully approved.`;

// //       await client.messages.create({
// //         body: message,
// //         from: process.env.TWILIO_PHONE_NUMBER,
// //         to: phoneNumber,
// //       });

// //       console.log(`Success SMS sent to ${phoneNumber}`);
// //     } catch (error) {
// //       console.error("Error sending loan SMS:", error);
// //     }
// //   });



// // ✅ Daily Due Reminder (using Scheduler from v2)
// exports.sendDueReminders = onSchedule(
//   {
//     schedule: 'every day 18:30',
//     timeZone: 'Asia/Kolkata',
//     region: 'asia-south1',
//   },
//   async () => {
//     const now = new Date();
//     now.setHours(0, 0, 0, 0);
//     const today = admin.firestore.Timestamp.fromDate(now);

//     const db = admin.firestore();
//     const loanSnapshot = await db.collection('loanDetails').get();

//     const jobs = [];

//     for (const loanDoc of loanSnapshot.docs) {
//       const loanData = loanDoc.data();
//       const customerId = loanData.customer_id;
//       const customerName = loanData.customer_name;
//       const loanId = loanDoc.id;

//       if (!customerId || !customerName) continue;

//       // Get phone number from customerDetails
//       const customerDoc = await db.collection('customerDetails').doc(customerId).get();
//       if (!customerDoc.exists) continue;

//       const phoneNumber = customerDoc.data().phone_number;
//       if (!phoneNumber) continue;

//       // Get repayments subcollection
//       const repaymentSnapshot = await db
//         .collection('loanDetails')
//         .doc(loanId)
//         .collection('repayments')
//         .where('due_date', '<=', today)
//         .where('is_paid', '==', false)
//         .where('reminder_sent', '!=', true) // Optional: to avoid duplicate reminders
//         .get();

//       for (const repayDoc of repaymentSnapshot.docs) {
//         const repayData = repayDoc.data();

//         const message = `Hi ${customerName}, this is a reminder that your repayment of ₹${repayData.repayment_amount} for loan ${loanId} is due today.`;

//         // 📤 Send SMS
//         const send = client.messages.create({
//           body: message,
//           from: process.env.TWILIO_PHONE_NUMBER,
//           to: phoneNumber,
//         });

//         // 📤 Send WhatsApp
//         const whatsappPromise = client.messages.create({
//           body: message,
//           from: 'whatsapp:' + process.env.TWILIO_WHATSAPP_NUMBER, // must be sandbox or approved number
//           to: 'whatsapp:' + phone,
//         });

//         const updatePromise = repayDoc.ref.update({ reminder_sent: true });

//         // Group them together
//         jobs.push(Promise.all([smsPromise, whatsappPromise, updatePromise]));
//       }
//     }

//     await Promise.all(jobs);
//     console.log(`✅ Total reminders sent: ${jobs.length}`);
//   }
// );

// =================================//================================
require("dotenv").config();

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const twilio = require("twilio");

admin.initializeApp();
const db = admin.firestore(); // ✅ Global db reference

const client = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

// ✅ 1. Loan Created Trigger (Gen 2)
exports.onLoanCreated = onDocumentCreated(
  {
    document: 'loanDetails/{loanId}',
    region: 'asia-south1',
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      console.log("No document data found.");
      return;
    }

    const data = snapshot.data();

    const customerId = data.customer_id;
    const loanAmount = data.loan_amount;
    const customerName = data.customer_name;

    if (!customerId || !loanAmount || !customerName) {
      console.log("Missing required loan data.");
      return;
    }

    try {
      const customerRef = db.collection("customerDetails").doc(customerId);
      const customerSnap = await customerRef.get();

      if (!customerSnap.exists) {
        console.log(`Customer ${customerId} not found.`);
        return;
      }

      const phone = customerSnap.data().phone_number;
      if (!phone) {
        console.log("Phone number missing.");
        return;
      }

      const message = `Hi ${customerName}, your loan of ₹${loanAmount} has been successfully approved.`;

      const smsPromise = client.messages.create({
        body: message,
        from: process.env.TWILIO_PHONE_NUMBER,
        to: phone,
      });

      const whatsappPromise = client.messages.create({
        body: message,
        from: process.env.TWILIO_WHATSAPP_NUMBER,
        to: 'whatsapp:' + phone,
      });

      await Promise.all([smsPromise, whatsappPromise]);
      console.log(`✅ SMS & WhatsApp sent to ${phone}`);
    } catch (err) {
      console.error("❌ Error sending messages:", err);
    }
  }
);

// ✅ 2. Due Reminder Trigger (Gen 2)
exports.sendDueReminders = onSchedule(
  {
    schedule: 'every day 21:45',
    timeZone: 'Asia/Kolkata',
    region: 'asia-south1',
  },
  async () => {
    const now = new Date();
    now.setHours(0, 0, 0, 0);
    const today = admin.firestore.Timestamp.fromDate(now);

    const loanSnapshot = await db.collection('loanDetails').get();
    const jobs = [];

    for (const loanDoc of loanSnapshot.docs) {
      const loanData = loanDoc.data();
      const customerId = loanData.customer_id;
      const customerName = loanData.customer_name;
      const loanId = loanDoc.id;

      if (!customerId || !customerName) continue;

      const customerDoc = await db.collection('customerDetails').doc(customerId).get();
      if (!customerDoc.exists) continue;

      const phoneNumber = customerDoc.data().phone_number;
      if (!phoneNumber) continue;

      const repaymentSnapshot = await db
        .collection('loanDetails')
        .doc(loanId)
        .collection('repayments')
        .where('due_date', '<=', today)
        .where('is_paid', '==', false)
        .where('reminder_sent', '!=', true)
        .get();

      for (const repayDoc of repaymentSnapshot.docs) {
        const repayData = repayDoc.data();
        const message = `Hi ${customerName}, this is a reminder that your repayment of ₹${repayData.repayment_amount} for loan ${loanId} is due today.`;

        const smsPromise = client.messages.create({
          body: message,
          from: process.env.TWILIO_PHONE_NUMBER,
          to: phoneNumber,
        });

        const whatsappPromise = client.messages.create({
          body: message,
          from: process.env.TWILIO_WHATSAPP_NUMBER,
          to: 'whatsapp:' + phoneNumber,
        });

        const updatePromise = repayDoc.ref.update({ reminder_sent: true });

        jobs.push(Promise.all([smsPromise, whatsappPromise, updatePromise]));
      }
    }

    await Promise.all(jobs);
    console.log(`✅ Total reminders sent: ${jobs.length}`);
  }
);
