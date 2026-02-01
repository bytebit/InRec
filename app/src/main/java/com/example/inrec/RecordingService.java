package com.example.inrec;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.media.MediaRecorder;
import android.media.projection.MediaProjection;
import android.media.projection.MediaProjectionManager;
import android.os.Build;
import android.os.Environment;
import android.os.IBinder;
import android.util.Log;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class RecordingService extends Service {

    private static final String CHANNEL_ID = "RecordingServiceChannel";
    private static final int NOTIFICATION_ID = 1;

    private MediaProjection mediaProjection;
    private MediaRecorder mediaRecorder;
    private String outputFilePath;

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannel();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null) {
            int resultCode = intent.getIntExtra("resultCode", 0);
            Intent data = intent.getParcelableExtra("data");
            startRecording(resultCode, data);
        }
        return START_NOT_STICKY;
    }

    private void startRecording(int resultCode, Intent data) {
        MediaProjectionManager mediaProjectionManager = (MediaProjectionManager) getSystemService(MEDIA_PROJECTION_SERVICE);
        mediaProjection = mediaProjectionManager.getMediaProjection(resultCode, data);

        mediaRecorder = new MediaRecorder();
        
        // 适配华为手机的音频源选择
        int audioSource;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10+/HarmonyOS 2+ 用UNPROCESSED
            audioSource = MediaRecorder.AudioSource.UNPROCESSED;
        } else {
            // EMUI 9.x 用REMOTE_SUBMIX
            audioSource = MediaRecorder.AudioSource.REMOTE_SUBMIX;
        }
        mediaRecorder.setAudioSource(audioSource);

        // 华为机型推荐的输出格式/编码
        mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
        mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);

        // 华为机型音质优化参数
        mediaRecorder.setAudioSamplingRate(48000); // 华为音频总线默认48kHz采样率
        mediaRecorder.setAudioEncodingBitRate(192000); // 192kbps保证高清音质
        mediaRecorder.setAudioChannels(2); // 立体声

        // 设置输出路径到download目录，m4a格式
        outputFilePath = getOutputFilePath();
        mediaRecorder.setOutputFile(outputFilePath);

        try {
            mediaRecorder.prepare();
            mediaRecorder.start();
            startForeground(NOTIFICATION_ID, createNotification());
            Log.d("RecordingService", "华为内录已启动，文件路径：" + outputFilePath);
        } catch (IOException e) {
            Log.e("RecordingService", "华为内录器初始化失败：" + e.getMessage());
            stopSelf();
        }
    }

    private String getOutputFilePath() {
        File downloadDir;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            downloadDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
        } else {
            downloadDir = new File(Environment.getExternalStorageDirectory(), "Download");
        }
        
        if (!downloadDir.exists()) {
            downloadDir.mkdirs();
        }
        
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(new Date());
        String fileName = "InRec_" + timeStamp + ".m4a";
        return new File(downloadDir, fileName).getAbsolutePath();
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Recording Service",
                    NotificationManager.IMPORTANCE_LOW
            );
            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(channel);
            }
        }
    }

    private Notification createNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder builder = new Notification.Builder(this, CHANNEL_ID)
                    .setContentTitle("InRec")
                    .setContentText("正在录音...")
                    .setSmallIcon(android.R.drawable.ic_btn_speak_now)
                    .setPriority(Notification.PRIORITY_LOW);
            return builder.build();
        } else {
            Notification.Builder builder = new Notification.Builder(this)
                    .setContentTitle("InRec")
                    .setContentText("正在录音...")
                    .setSmallIcon(android.R.drawable.ic_btn_speak_now)
                    .setPriority(Notification.PRIORITY_LOW);
            return builder.build();
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stopRecording();
    }

    private void stopRecording() {
        if (mediaRecorder != null) {
            try {
                mediaRecorder.stop();
                mediaRecorder.reset();
                mediaRecorder.release();
                Log.d("RecordingService", "华为内录已停止，文件已保存：" + outputFilePath);
            } catch (Exception e) {
                Log.e("RecordingService", "华为内录停止失败：" + e.getMessage());
            } finally {
                mediaRecorder = null;
            }
        }

        if (mediaProjection != null) {
            mediaProjection.stop();
            mediaProjection = null;
        }

        stopForeground(true);
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
