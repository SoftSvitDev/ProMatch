import UIKit

extension UIViewController {
    private static var keyboardObserverKey: UInt8 = 0

    /// Adds keyboard tracking so the bottom safe area expands while the keyboard is visible.
    /// Anything anchored to `view.safeAreaLayoutGuide.bottom` (Save buttons, scroll-view bottoms)
    /// automatically shifts above the keyboard — no per-screen layout code needed.
    /// Call once in `viewDidLoad` of any screen that contains editable inputs.
    func enableKeyboardAvoidance() {
        guard objc_getAssociatedObject(self, &Self.keyboardObserverKey) == nil else { return }
        let observer = KeyboardAvoidanceObserver(viewController: self)
        objc_setAssociatedObject(self, &Self.keyboardObserverKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    /// Installs both:
    ///   1. Tap-anywhere-outside-input to dismiss.
    ///   2. Return-key to dismiss for every existing `UITextField` in the view hierarchy.
    /// Call again after dynamically adding new text fields (e.g. wizards that rebuild content).
    func enableKeyboardDismissal() {
        installDismissKeyboardOnTap()
        wireReturnDismissOnAllTextFields()
    }

    /// Tap anywhere outside an input to dismiss the keyboard.
    func installDismissKeyboardOnTap() {
        // Avoid attaching multiple recognizers if called twice.
        if view.gestureRecognizers?.contains(where: { $0.name == "promatch.dismissKeyboard" }) == true { return }
        let tap = UITapGestureRecognizer(target: self, action: #selector(promatch_dismissKeyboardFromTap))
        tap.cancelsTouchesInView = false
        tap.name = "promatch.dismissKeyboard"
        tap.delegate = DismissTapDelegate.shared
        view.addGestureRecognizer(tap)
    }

    /// Walks the current view hierarchy and wires Return-key dismissal on every `UITextField`.
    /// Safe to call multiple times — duplicate targets are no-ops because the action is the same.
    func wireReturnDismissOnAllTextFields() {
        wireReturn(in: view)
    }

    private func wireReturn(in view: UIView) {
        for sub in view.subviews {
            if let tf = sub as? UITextField {
                tf.removeTarget(self, action: #selector(promatch_returnKeyDismiss(_:)), for: .editingDidEndOnExit)
                tf.addTarget(self, action: #selector(promatch_returnKeyDismiss(_:)), for: .editingDidEndOnExit)
            }
            wireReturn(in: sub)
        }
    }

    @objc fileprivate func promatch_dismissKeyboardFromTap() {
        view.endEditing(true)
    }

    @objc fileprivate func promatch_returnKeyDismiss(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}

/// Lets the tap-to-dismiss gesture coexist with controls. The gesture is suppressed
/// when the touch lands inside a `UIControl` (text fields, buttons, switches, …) so
/// they keep working normally.
private final class DismissTapDelegate: NSObject, UIGestureRecognizerDelegate {
    static let shared = DismissTapDelegate()
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var current = touch.view
        while let v = current {
            if v is UIControl { return false }
            current = v.superview
        }
        return true
    }
}

private final class KeyboardAvoidanceObserver {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(keyboardWillChangeFrame(_:)),
                       name: UIResponder.keyboardWillChangeFrameNotification,
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(keyboardWillHide(_:)),
                       name: UIResponder.keyboardWillHideNotification,
                       object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let vc = viewController,
              let frameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curveRaw = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else {
            return
        }

        let endFrame = frameValue.cgRectValue
        let converted = vc.view.convert(endFrame, from: nil)
        let intersection = vc.view.bounds.intersection(converted)
        let coveredHeight = max(0, intersection.height)
        let windowSafeBottom = vc.view.window?.safeAreaInsets.bottom ?? 0
        let extra = max(0, coveredHeight - windowSafeBottom)

        animate(duration: duration, curveRaw: curveRaw) {
            vc.additionalSafeAreaInsets.bottom = extra
            vc.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let vc = viewController,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curveRaw = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else {
            return
        }
        animate(duration: duration, curveRaw: curveRaw) {
            vc.additionalSafeAreaInsets.bottom = 0
            vc.view.layoutIfNeeded()
        }
    }

    private func animate(duration: TimeInterval, curveRaw: Int, animations: @escaping () -> Void) {
        let options = UIView.AnimationOptions(rawValue: UInt(curveRaw) << 16)
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [.beginFromCurrentState, options],
                       animations: animations)
    }
}
