import mongoose from "mongoose";

const reportSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: false
  },
  trainNo: {
    type: String,
    required: true
  },
  trainName: {
    type: String,
    required: true
  },
  category: {
    type: String,
    enum: [
      'Train rescheduled/cancelled/diverted',
      'Train showing wrong info',
      'Other'
    ],
    required: true
  },
  message: {
    type: String,
    default: ''
  },
  status: {
    type: String,
    enum: ['pending', 'reviewed', 'resolved'],
    default: 'pending'
  }
}, { timestamps: true });

reportSchema.index({ trainNo: 1 });
reportSchema.index({ userId: 1 });
reportSchema.index({ createdAt: -1 });

export const TrainReport = mongoose.model('TrainReport', reportSchema);
