# Application of a Sports Activity Monitoring System for Individuals with Chronic Illnesses

## Overview

This project focuses on developing a sports activity monitoring system tailored for individuals with chronic illnesses. The system leverages advanced technologies to offer continuous monitoring and personalized feedback, aiming to improve health outcomes and enhance the quality of life for patients.

## Objectives

- **Real-Time Monitoring**: Track physical activity and vital signs in real-time using wearable sensors and video analysis.
- **Personalized Feedback**: Provide customized activity recommendations based on individual health data.
- **Enhanced Health Management**: Support patients in managing their chronic conditions more effectively through continuous health insights.

## Technology Stack

- **Mobile Application**: Built using Flutter to capture and display real-time data.
- **Backend Server**: Powered by Django to handle data processing and analysis.
- **Deep Learning Model**: YOLOv8 for posture detection and angle calculation.
- **Biometric Sensors**: Max30102 for monitoring heart rate and oxygen levels.

## System Architecture

1. **Mobile Application**: 
   - Captures real-time video of the user’s physical activity.
   - Displays vital signs and activity data to the user.

2. **Backend Server**: 
   - Receives video data from the mobile application.
   - Processes the video using YOLOv8 to detect key points and calculate joint angles.
   - Analyzes biometric data from sensors and provides feedback.

3. **Biometric Sensors**:
   - Measures heart rate and oxygen levels.
   - Sends data to the mobile application for real-time display.

## Key Features

- **Activity Monitoring**: Real-time tracking of physical activities and vital signs.
- **Health Insights**: Instant feedback on activity performance and health metrics.
- **Data Storage**: Secure storage of health data for ongoing monitoring and analysis.

## User Interface Examples

### 1. **Home Page**
   - **Real-Time Activity Feed**: Shows current physical activity and biometric data.
   - **Health Metrics**: Displays heart rate, oxygen levels, and activity statistics.

   ![Home Screen](pictures/home_screen.png)

### 2. **Activity Monitoring Screen**
   - **Video Feed**: Live video of the user’s activity.
   - **Posture Analysis**: Overlay showing detected key points and angles.

   ![Activity Monitoring Screen](pictures/activity_monitoring_screen.png)

### 3. **Health Insights Screen**
   - **Historical Data**: Graphs and charts showing historical health metrics and activity trends.
   - **Recommendations**: Personalized suggestions based on past activity and health data.

   ![Health Insights Screen](pictures/health_insights_screen.png)

## Benefits

- **Improved Health Management**: Enables patients to monitor their physical activity and health metrics continuously.
- **Personalized Recommendations**: Offers tailored activity suggestions based on individual health data.
- **Enhanced Patient Engagement**: Encourages active participation in managing chronic illnesses through real-time feedback.

## Future Enhancements

- **Integration with Additional Sensors**: Incorporate more types of biometric sensors for comprehensive health monitoring.
- **Advanced Analytics**: Implement advanced data analytics for deeper insights into health trends and patterns.
- **User Feedback**: Continuously gather and incorporate user feedback to refine and improve the system.

## Conclusion

The sports activity monitoring system represents a significant advancement in managing chronic illnesses by combining real-time monitoring with personalized health insights. By leveraging cutting-edge technology, the system aims to empower individuals with chronic conditions to better manage their health and improve their overall well-being.

---

**Keywords**: Sports Activity Monitoring, Chronic Illnesses, Real-Time Monitoring, Biometric Sensors, Deep Learning, YOLOv8, Health Management
