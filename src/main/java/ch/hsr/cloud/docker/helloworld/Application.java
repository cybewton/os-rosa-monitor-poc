package ch.hsr.cloud.docker.helloworld;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import com.microsoft.applicationinsights.extensibility.TelemetryInitializer;
import com.microsoft.applicationinsights.telemetry.TelemetryContext;

@SpringBootApplication
@RestController
@EnableScheduling
public class Application {

    @RequestMapping("/")
    public String home() {
        return "Hello Docker Cloud World!";
    }

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @Scheduled(fixedRate = 30000)
    public void sendGetRequest() {
        RestTemplate restTemplate = new RestTemplate();
        String response = restTemplate.getForObject("https://www.google.com", String.class);
        System.out.println("Response from Google: " + response);
    }

    @Bean
    public TelemetryInitializer telemetryInitializer() {
        return telemetry -> {
            TelemetryContext context = telemetry.getContext();
            context.getCloud().setRole("hello-world");
        };
    }	
}