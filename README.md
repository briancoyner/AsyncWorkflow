## Async Workflow

All apps have asynchronous workflows. Apple's `NSOperation` and `NSOperationQueue` provide a foundation for building arbitrarily complex workflows. This demo code coincides with my [STL CocoaHeads](https://www.meetup.com/St-Louis-CocoaHeads/events/253392866/) talk on techniques for building "async workflows". 

The demo code shows how to:
- use dependent operations
- pass data between operations using a thread-safe key/value store (i.e `Session`)
- track progress using `NSProgress`
- support an easy to understand cancellation policy
- allow app background execution (with just a few lines of code)


## Presentation Slides

Be sure to review the CocoaHeads [presentation slides](AsyncWorkflow.pdf) for additional notes and details.

## Additional Resources

Here's a short list of related WWDC videos 
- WWDC 2015 [Advanced NSOperations](https://developer.apple.com/videos/play/wwdc2015/226/)
- WWDC 2015 [Best Practices In Progress Reporting](https://developer.apple.com/videos/play/wwdc2015/232/)
- WWDC 2017 [Modernizing Grand Central Dispatch Usage](https://developer.apple.com/videos/play/wwdc2017/706/)
