//
//  Created by Brian Coyner on 8/9/18.
//  Copyright © 2018 Brian Coyner. All rights reserved.
//

import Foundation
import UIKit

import AsyncWorkflow

/// A very simple view controller that executes an async workflow on
/// a privately owned operation queue. Progress is tracked using
/// a standard UIKit `UIProgressView`.

final class DemoWorkflowViewController: UIViewController {

    fileprivate enum State {
        case idle
        case busy(OperationQueue, Progress)
    }

    fileprivate var state: State = .idle {
        didSet {
            transition(from: oldValue, to: state)
        }
    }

    fileprivate let workflowStrategy: WorkflowStrategy

    fileprivate lazy var progressView = self.lazyProgressView()
    fileprivate lazy var statusLabel = self.lazyStatusLabel()
    fileprivate lazy var executeButton = self.lazyGoButton()
    fileprivate lazy var cancelButton = self.lazyCancelButton()

    init(workflowStrategy: WorkflowStrategy) {
        self.workflowStrategy = workflowStrategy

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DemoWorkflowViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let contentView = makeContentView()
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])

        transitionToIdleState()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //
        // Often times it's appropriate to cancel an async workflow when the user
        // leaves a view. This is especially true when moving "back" (i.e. popping off
        // the navigation stack or canceling a modal view controller). Sometimes, though,
        // you want to keep an async workflow running if the user is allowed to move
        // "forward" (i.e. pushing a "detail" view on the navigation stack).
        //
        // If needed, you can use the `isBeingDismissed` and `isMovingFromParent` to know
        // if the user is going "back" or going "forward".
        //

        userTappedCancel()
    }
}

extension DemoWorkflowViewController {

    @objc
    fileprivate func userTappedGo() {
        guard case .idle = state else {
            print("Already busy.")
            return
        }

        //
        // STEP 1:
        // Create a "controller" operation that executes the operations
        // provided by the strategy. Remember that the "controller" operation
        // owns a private operation queue, which makes managing/ cancelling the
        // strategy's super easy.
        //

        let operation = WorkflowControllerOperation(strategy: workflowStrategy)

        //
        // STEP 2:
        // Register a completion block (this is part of the `NSOperation` API.
        // In production, developers should first check the session for an `error`.
        // If there is not an error, then pull out the "answer" from the workflow.
        //
        // Remember to dispatch to the main queue if you need to display the "answer"
        // to the user.
        //
        // This demo implementation does not include a convenience "delegate" API on
        // the workflow controller.
        //
        // The delegate API could have a few methods:
        // - will start executing workflow (includes access to the controller's root `Progress`)
        // - did cancel workflow
        // - did complete executing workflow (with error)
        //

        operation.completionBlock = { [weak self] in

            // STEP 4:
            // The workflow completed.
            //
            // Remember to:
            // - check for cancelation/ errors
            // - dispatch any UI related work to the main queue
            //
            // Review the note above about adding a delegate API.
            //

            let session = operation.session
            print("Session Details: \(session.copyOfSessionInfo()); Error: \(String(describing: session.error))")

            DispatchQueue.main.async {
                self?.state = .idle
            }
        }

        //
        // STEP 3:
        // Execute the workflow by submitting the controller operation to queue.
        // What queue you submit to depends on your app's architecture. For this demo,
        // a new operation is created each time the workflow executes. This works well
        // for a demo, but not production. In the end it's up to your app's architectural
        // requirements on how to set up and manage your queues.
        //

        let operationQueue = OperationQueue()
        state = .busy(operationQueue, operation.progress)
        operationQueue.addOperation(operation)
    }

    @objc
    fileprivate func userTappedCancel() {
        print("User tapped cancel")
        switch state {
        case .busy(let operationQueue, _):
            // Cancelling does not immediately transition to the `.idle` state
            // because the workflow may take a bit to actually end all operations.
            // Once the workflow completes, the state transitions  to `.idle`.
            transitionToCancelingState()
            operationQueue.cancelAllOperations()
        case .idle:
            break
        }
    }
}

extension DemoWorkflowViewController {

    fileprivate func transition(from oldState: State, to newState: State) {
        switch (oldState, newState) {
        case (.idle, .busy(_, let progress)):
            transitionToBusyState(observing: progress)
        case (.busy, .idle):
            transitionToIdleState()
        case (.idle, .idle), (.busy, .busy):
            break
        }
    }

    fileprivate func transitionToIdleState() {
        progressView.observedProgress = nil
        statusLabel.text = "Tap to execute"

        cancelButton.isHidden = true
        executeButton.isHidden = false
    }

    fileprivate func transitionToBusyState(observing progress: Progress) {
        progressView.observedProgress = progress
        statusLabel.text = "executing..."

        cancelButton.isHidden = false
        executeButton.isHidden = true
    }

    fileprivate func transitionToCancelingState() {
        statusLabel.text = "canceling..."

        cancelButton.isHidden = true
        executeButton.isHidden = true
    }
}

extension DemoWorkflowViewController {

    fileprivate func makeContentView() -> UIView {

        return UIStackView(
            arrangedSubviews: [
                progressView,
                statusLabel,
                makeButtonContentView()
            ],
            axis: .vertical,
            alignment: .fill,
            distribution: .fill
        )
    }
}

extension DemoWorkflowViewController {

    fileprivate func lazyProgressView() -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false

        return progressView
    }

    fileprivate func lazyStatusLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .footnote)

        return label
    }

    fileprivate func lazyGoButton() -> UIButton {
        return makeActionButton(withTitle: "Go", selector: #selector(userTappedGo))
    }

    fileprivate func lazyCancelButton() -> UIButton {
        return makeActionButton(withTitle: "Cancel", selector: #selector(userTappedCancel))
    }
}

extension DemoWorkflowViewController {

    fileprivate func makeButtonContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(executeButton)
        view.addSubview(cancelButton)

        executeButton.constrain(toView: view)
        cancelButton.constrain(toView: view)

        return view
    }

    fileprivate func makeActionButton(withTitle title: String, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle(title, for: .normal)
        button.addTarget(self, action: selector, for: .primaryActionTriggered)

        return button
    }
}
