import ballerina/io;
import ballerina/lang.runtime;
import nuvindu/pubsub;

public function main() returns error? {
    // pubsub:PubSub pubsub = new(); // to automatically create topics
    pubsub:PubSub pubsub = new(autoCreateTopics = false);
    check pubsub.createTopic("topic");
    
    string[] alerts = 
    [
        "Luna cryptocurrency collapses 98% overnight",
        "EU slashes forecast for economic growth as war's fallout deepens",
        "India asks state firms to consider buying Russian oil assets"
    ];

    // Create two subscribers
    stream<string, error?> subscriber1 = check pubsub.subscribe("topic");
    stream<string, error?> subscriber2 = check pubsub.subscribe("topic");

    worker A {
        foreach string alert in alerts {
            pubsub:Error? publish = pubsub.publish("topic", alert, 30);
            if publish !is pubsub:Error {
                io:println("News alert published.");
            }
            runtime:sleep(5);
        }
    }

    worker B {
        foreach int i in 0 ..< 3 {
	        record {|string value;|}|error? newValue = subscriber1.next();
            if newValue !is error? {
                io:println("Subscriber 1: ", newValue.value);
            }
            newValue = subscriber2.next();
            if newValue !is error? {
                io:println("Subscriber 2: ", newValue.value);
            }

            // if i === 1 {
            //     // Subscriber will be unsubscribed from the topic when the stream is closed
            //     error? close = subscriber2.close();
            //     if close is error {
            //         io:println("Error: ", close);
            //     }
            // }
        }
    }
}
