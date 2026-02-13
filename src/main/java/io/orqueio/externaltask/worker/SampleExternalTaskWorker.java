package io.orqueio.externaltask.worker;

import io.orqueio.bpm.client.ExternalTaskClient;
import io.orqueio.bpm.client.topic.TopicSubscription;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.Map;

@Slf4j
@Component
public class SampleExternalTaskWorker implements CommandLineRunner {

    @Value("${orqueio.base-url}")
    private String orqueioBaseUrl;

    @Override
    public void run(String... args) throws InterruptedException {
        log.info("Starting External Task Worker...");
        log.info("Connecting to OrqueIO at: {}", orqueioBaseUrl);

        // Wait for OrqueIO engine to be fully started
        log.info("Waiting 5 seconds for OrqueIO engine to initialize...");
        Thread.sleep(5000);

        ExternalTaskClient client = ExternalTaskClient.create()
                .baseUrl(orqueioBaseUrl)
                .build();

        // Subscribe to external task topic
        TopicSubscription subscription = client.subscribe("process-data")
                .lockDuration(10000) // 10 seconds
                .handler((externalTask, externalTaskService) -> {
                    try {
                        log.info("External task received: {}", externalTask.getId());
                        log.info("Activity ID: {}", externalTask.getActivityId());
                        log.info("Process Instance ID: {}", externalTask.getProcessInstanceId());

                        // Get variables from the process
                        Map<String, Object> variables = externalTask.getAllVariables();
                        log.info("Variables: {}", variables);

                        // Process the task (example: simple data transformation)
                        String inputData = (String) variables.get("inputData");
                        String processedData = processData(inputData);

                        log.info("Input data: {}", inputData);
                        log.info("Processed data: {}", processedData);

                        // Complete the task with result variables
                        externalTaskService.complete(externalTask,
                            Map.of("processedData", processedData,
                                   "status", "SUCCESS"));

                        log.info("External task completed successfully: {}", externalTask.getId());

                    } catch (Exception e) {
                        log.error("Error processing external task: {}", e.getMessage(), e);

                        // Handle failure
                        externalTaskService.handleFailure(externalTask,
                            e.getMessage(),
                            "Error details: " + e.getClass().getName(),
                            3, // retries
                            5000); // retry timeout in ms
                    }
                })
                .open();

        log.info("External Task Worker is now listening to topic: process-data");

        // Keep the application running
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            log.info("Shutting down External Task Worker...");
            subscription.close();
            client.stop();
        }));
    }

    private String processData(String input) {
        if (input == null) {
            return "No data provided";
        }
        // Example processing: convert to uppercase and add prefix
        return "PROCESSED: " + input.toUpperCase();
    }
}
