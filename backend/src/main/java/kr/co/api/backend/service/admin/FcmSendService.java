package kr.co.api.backend.service.admin;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;

import org.springframework.stereotype.Service;

@Service
public class FcmSendService {
    public void sendToTopic(String topic, String title, String body) {
        try {
            Message msg = Message.builder()
                    .setTopic(topic)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .build();

            String messageId = FirebaseMessaging.getInstance().send(msg);
            System.out.println("[FCM SEND OK] messageId=" + messageId + ", topic=" + topic);
        } catch (Exception e) {
            System.out.println("[FCM SEND FAIL] topic=" + topic + " err=" + e.getMessage());
            throw new RuntimeException(e);
        }
    }
}
