//
//  HandTrackingModel.swift
//  HandTracking
//
//  Created by IVAN CAMPOS on 2/23/24.
//

// TODO: Needs heavy refactoring.  An example has been modified for development speed.
import ARKit
import RealityKit
import SwiftUI

struct HandsUpdates {
    var left: HandAnchor?
    var right: HandAnchor?
}

class HandTrackingModel: ObservableObject {
    let session = ARKitSession()
    var handTrackingProvider = HandTrackingProvider()
    let worldTrackingProvider = WorldTrackingProvider()
    var deviceTransform = Transform()
    private var numFrames = 0
    private var startTime: TimeInterval = CFAbsoluteTimeGetCurrent()

    @Published var latestHandTracking: HandsUpdates = .init(
        left: nil,
        right: nil
    )

    // State variables for sphere model entities
    @Published var leftWristModelEntity = ModelEntity.createHandEntity()
    @Published var leftThumbKnuckleModelEntity = ModelEntity.createHandEntity()
    @Published var leftThumbIntermediateBaseModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftThumbIntermediateTipModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftThumbTipModelEntity = ModelEntity.createHandEntity()
    @Published var leftIndexFingerMetacarpalModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftIndexFingerKnuckleModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftIndexFingerIntermediateBaseModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftIndexFingerIntermediateTipModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftIndexFingerTipModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftMiddleFingerMetacarpalModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftMiddleFingerKnuckleModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftMiddleFingerIntermediateBaseModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftMiddleFingerIntermediateTipModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftMiddleFingerTipModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftRingFingerMetacarpalModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftRingFingerKnuckleModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftRingFingerIntermediateBaseModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftRingFingerIntermediateTipModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftRingFingerTipModelEntity = ModelEntity.createHandEntity()
    @Published var leftLittleFingerMetacarpalModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftLittleFingerKnuckleModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftLittleFingerIntermediateBaseModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftLittleFingerIntermediateTipModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftLittleFingerTipModelEntity =
        ModelEntity.createHandEntity()
    @Published var leftForearmWristModelEntity = ModelEntity.createHandEntity()

    // State variables for box model entities
    @Published var leftForearmArmModelEntity = ModelEntity.createArmEntity()

    // Repeat the pattern for right hand and forearm entities
    @Published var rightWristModelEntity = ModelEntity.createHandEntity()
    @Published var rightThumbKnuckleModelEntity = ModelEntity.createHandEntity()
    @Published var rightThumbIntermediateBaseModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightThumbIntermediateTipModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightThumbTipModelEntity = ModelEntity.createHandEntity()
    @Published var rightIndexFingerMetacarpalModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightIndexFingerKnuckleModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightIndexFingerIntermediateBaseModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightIndexFingerIntermediateTipModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightIndexFingerTipModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightMiddleFingerMetacarpalModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightMiddleFingerKnuckleModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightMiddleFingerIntermediateBaseModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightMiddleFingerIntermediateTipModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightMiddleFingerTipModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightRingFingerMetacarpalModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightRingFingerKnuckleModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightRingFingerIntermediateBaseModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightRingFingerIntermediateTipModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightRingFingerTipModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightLittleFingerMetacarpalModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightLittleFingerKnuckleModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightLittleFingerIntermediateBaseModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightLittleFingerIntermediateTipModelEntity =
        ModelEntity.createHandEntity()
    @Published var rightLittleFingerTipModelEntity =
        ModelEntity.createHandEntity()

    @Published var rightForearmWristModelEntity = ModelEntity.createHandEntity()
    @Published var rightForearmArmModelEntity = ModelEntity.createArmEntity()

    func handTracking() {
        if HandTrackingProvider.isSupported {
            Task {
                do {
                    try await session.run([
                        handTrackingProvider, worldTrackingProvider,
                    ])
                    for await update in handTrackingProvider.anchorUpdates {
                        DispatchQueue.main.async {  // Ensure updates are on the main thread
                            switch update.event {
                            case .updated:
                                let anchor = update.anchor
                                if !anchor.isTracked {
                                    return  // Use 'return' instead of 'continue' outside loops
                                }
                                if anchor.chirality == .left {
                                    self.latestHandTracking.left = anchor
                                } else if anchor.chirality == .right {
                                    self.latestHandTracking.right = anchor
                                }
                            default:
                                break
                            }
                        }

                        guard worldTrackingProvider.state == .running else {
                            logger.error(
                                "World tracking provider is not running."
                            )
                            return
                        }

                        // Query the device anchor at the current time.
                        guard
                            let deviceAnchor =
                                worldTrackingProvider.queryDeviceAnchor(
                                    atTimestamp: CACurrentMediaTime()
                                )
                        else {
                            logger.error("Could not get deviceAnchor.")
                            return
                        }

                        logger.trace("Getting transform of the device.")
                        // Find the transform of the device.
                        deviceTransform = Transform(
                            matrix: deviceAnchor.originFromAnchorTransform
                        )
                    }
                } catch {
                    print("Error starting hand tracking: \(error)")
                }
            }
        }
    }

    static func getCodableMatrix(mat: simd_float3x3) -> [[Double]] {
        var codableTransform: [[Double]] = [[Double]]()
        for rowNum in 0...2 {
            var row = [Double]()
            for colNum in 0...2 {
                row.append(Double(mat[rowNum, colNum]))
            }
            codableTransform.append(row)
        }
        return codableTransform
    }

    static func getCodableMatrix(mat: simd_float4x4) -> [[Double]] {
        var codableTransform: [[Double]] = [[Double]]()
        for rowNum in 0...3 {
            var row = [Double]()
            for colNum in 0...3 {
                row.append(Double(mat[rowNum, colNum]))
            }
            codableTransform.append(row)
        }
        return codableTransform
    }

    func getCodableTransform(transform: Transform) -> [[Double]] {
        let mat = transform.matrix
        return HandTrackingModel.getCodableMatrix(mat: mat)
    }

    func computeTransformHeartTracking() {
        guard let leftHandAnchor = latestHandTracking.left,
            let rightHandAnchor = latestHandTracking.right,
            leftHandAnchor.isTracked, rightHandAnchor.isTracked
        else {
            return
        }
        leftWristModelEntity.transform = getTransform(
            leftHandAnchor,
            .wrist,
            leftWristModelEntity.transform
        )
        leftThumbKnuckleModelEntity.transform = getTransform(
            leftHandAnchor,
            .thumbKnuckle,
            leftThumbKnuckleModelEntity.transform
        )
        leftThumbIntermediateBaseModelEntity.transform = getTransform(
            leftHandAnchor,
            .thumbIntermediateBase,
            leftThumbIntermediateBaseModelEntity.transform
        )
        leftThumbIntermediateTipModelEntity.transform = getTransform(
            leftHandAnchor,
            .thumbIntermediateTip,
            leftThumbIntermediateTipModelEntity.transform
        )
        leftThumbTipModelEntity.transform = getTransform(
            leftHandAnchor,
            .thumbTip,
            leftThumbTipModelEntity.transform
        )
        leftIndexFingerMetacarpalModelEntity.transform = getTransform(
            leftHandAnchor,
            .indexFingerMetacarpal,
            leftIndexFingerMetacarpalModelEntity.transform
        )
        leftIndexFingerKnuckleModelEntity.transform = getTransform(
            leftHandAnchor,
            .indexFingerKnuckle,
            leftMiddleFingerKnuckleModelEntity.transform
        )
        leftIndexFingerIntermediateBaseModelEntity.transform = getTransform(
            leftHandAnchor,
            .indexFingerIntermediateBase,
            leftIndexFingerIntermediateBaseModelEntity.transform
        )
        leftIndexFingerIntermediateTipModelEntity.transform = getTransform(
            leftHandAnchor,
            .indexFingerIntermediateTip,
            leftIndexFingerIntermediateTipModelEntity.transform
        )
        leftIndexFingerTipModelEntity.transform = getTransform(
            leftHandAnchor,
            .indexFingerTip,
            leftIndexFingerTipModelEntity.transform
        )
        leftMiddleFingerMetacarpalModelEntity.transform = getTransform(
            leftHandAnchor,
            .middleFingerMetacarpal,
            leftMiddleFingerMetacarpalModelEntity.transform
        )
        leftMiddleFingerKnuckleModelEntity.transform = getTransform(
            leftHandAnchor,
            .middleFingerKnuckle,
            leftMiddleFingerKnuckleModelEntity.transform
        )
        leftMiddleFingerIntermediateBaseModelEntity.transform = getTransform(
            leftHandAnchor,
            .middleFingerIntermediateBase,
            leftMiddleFingerIntermediateBaseModelEntity.transform
        )
        leftMiddleFingerIntermediateTipModelEntity.transform = getTransform(
            leftHandAnchor,
            .middleFingerIntermediateTip,
            leftMiddleFingerIntermediateTipModelEntity.transform
        )
        leftMiddleFingerTipModelEntity.transform = getTransform(
            leftHandAnchor,
            .middleFingerTip,
            leftMiddleFingerTipModelEntity.transform
        )
        leftRingFingerMetacarpalModelEntity.transform = getTransform(
            leftHandAnchor,
            .ringFingerMetacarpal,
            leftRingFingerMetacarpalModelEntity.transform
        )
        leftRingFingerKnuckleModelEntity.transform = getTransform(
            leftHandAnchor,
            .ringFingerKnuckle,
            leftRingFingerKnuckleModelEntity.transform
        )
        leftRingFingerIntermediateBaseModelEntity.transform = getTransform(
            leftHandAnchor,
            .ringFingerIntermediateBase,
            leftRingFingerIntermediateBaseModelEntity.transform
        )
        leftRingFingerIntermediateTipModelEntity.transform = getTransform(
            leftHandAnchor,
            .ringFingerIntermediateTip,
            leftRingFingerIntermediateTipModelEntity.transform
        )
        leftRingFingerTipModelEntity.transform = getTransform(
            leftHandAnchor,
            .ringFingerTip,
            leftRingFingerTipModelEntity.transform
        )
        leftLittleFingerMetacarpalModelEntity.transform = getTransform(
            leftHandAnchor,
            .littleFingerMetacarpal,
            leftLittleFingerMetacarpalModelEntity.transform
        )
        leftLittleFingerKnuckleModelEntity.transform = getTransform(
            leftHandAnchor,
            .littleFingerKnuckle,
            leftLittleFingerKnuckleModelEntity.transform
        )
        leftLittleFingerIntermediateBaseModelEntity.transform = getTransform(
            leftHandAnchor,
            .littleFingerIntermediateBase,
            leftLittleFingerIntermediateBaseModelEntity.transform
        )
        leftLittleFingerIntermediateTipModelEntity.transform = getTransform(
            leftHandAnchor,
            .littleFingerIntermediateTip,
            leftLittleFingerIntermediateTipModelEntity.transform
        )
        leftLittleFingerTipModelEntity.transform = getTransform(
            leftHandAnchor,
            .littleFingerTip,
            leftLittleFingerTipModelEntity.transform
        )
        leftForearmWristModelEntity.transform = getTransform(
            leftHandAnchor,
            .forearmWrist,
            leftForearmWristModelEntity.transform
        )
        leftForearmArmModelEntity.transform = getTransform(
            leftHandAnchor,
            .forearmArm,
            leftForearmArmModelEntity.transform
        )

        rightWristModelEntity.transform = getTransform(
            rightHandAnchor,
            .wrist,
            rightWristModelEntity.transform
        )
        rightThumbKnuckleModelEntity.transform = getTransform(
            rightHandAnchor,
            .thumbKnuckle,
            rightThumbKnuckleModelEntity.transform
        )
        rightThumbIntermediateBaseModelEntity.transform = getTransform(
            rightHandAnchor,
            .thumbIntermediateBase,
            rightThumbIntermediateBaseModelEntity.transform
        )
        rightThumbIntermediateTipModelEntity.transform = getTransform(
            rightHandAnchor,
            .thumbIntermediateTip,
            rightThumbIntermediateTipModelEntity.transform
        )
        rightThumbTipModelEntity.transform = getTransform(
            rightHandAnchor,
            .thumbTip,
            rightThumbTipModelEntity.transform
        )
        rightIndexFingerMetacarpalModelEntity.transform = getTransform(
            rightHandAnchor,
            .indexFingerMetacarpal,
            rightIndexFingerMetacarpalModelEntity.transform
        )
        rightIndexFingerKnuckleModelEntity.transform = getTransform(
            rightHandAnchor,
            .indexFingerKnuckle,
            rightIndexFingerKnuckleModelEntity.transform
        )
        rightIndexFingerIntermediateBaseModelEntity.transform = getTransform(
            rightHandAnchor,
            .indexFingerIntermediateBase,
            rightIndexFingerIntermediateBaseModelEntity.transform
        )
        rightIndexFingerIntermediateTipModelEntity.transform = getTransform(
            rightHandAnchor,
            .indexFingerIntermediateTip,
            rightIndexFingerIntermediateTipModelEntity.transform
        )
        rightIndexFingerTipModelEntity.transform = getTransform(
            rightHandAnchor,
            .indexFingerTip,
            rightIndexFingerTipModelEntity.transform
        )
        rightMiddleFingerMetacarpalModelEntity.transform = getTransform(
            rightHandAnchor,
            .middleFingerMetacarpal,
            rightMiddleFingerMetacarpalModelEntity.transform
        )
        rightMiddleFingerKnuckleModelEntity.transform = getTransform(
            rightHandAnchor,
            .middleFingerKnuckle,
            rightMiddleFingerKnuckleModelEntity.transform
        )
        rightMiddleFingerIntermediateBaseModelEntity.transform = getTransform(
            rightHandAnchor,
            .middleFingerIntermediateBase,
            rightMiddleFingerIntermediateBaseModelEntity.transform
        )
        rightMiddleFingerIntermediateTipModelEntity.transform = getTransform(
            rightHandAnchor,
            .middleFingerIntermediateTip,
            rightMiddleFingerIntermediateTipModelEntity.transform
        )
        rightMiddleFingerTipModelEntity.transform = getTransform(
            rightHandAnchor,
            .middleFingerTip,
            rightMiddleFingerTipModelEntity.transform
        )
        rightRingFingerMetacarpalModelEntity.transform = getTransform(
            rightHandAnchor,
            .ringFingerMetacarpal,
            rightRingFingerMetacarpalModelEntity.transform
        )
        rightRingFingerKnuckleModelEntity.transform = getTransform(
            rightHandAnchor,
            .ringFingerKnuckle,
            rightRingFingerKnuckleModelEntity.transform
        )
        rightRingFingerIntermediateBaseModelEntity.transform = getTransform(
            rightHandAnchor,
            .ringFingerIntermediateBase,
            rightRingFingerIntermediateBaseModelEntity.transform
        )
        rightRingFingerIntermediateTipModelEntity.transform = getTransform(
            rightHandAnchor,
            .ringFingerIntermediateTip,
            rightRingFingerIntermediateTipModelEntity.transform
        )
        rightRingFingerTipModelEntity.transform = getTransform(
            rightHandAnchor,
            .ringFingerTip,
            rightRingFingerTipModelEntity.transform
        )
        rightLittleFingerMetacarpalModelEntity.transform = getTransform(
            rightHandAnchor,
            .littleFingerMetacarpal,
            rightLittleFingerMetacarpalModelEntity.transform
        )
        rightLittleFingerKnuckleModelEntity.transform = getTransform(
            rightHandAnchor,
            .littleFingerKnuckle,
            rightLittleFingerKnuckleModelEntity.transform
        )
        rightLittleFingerIntermediateBaseModelEntity.transform = getTransform(
            rightHandAnchor,
            .littleFingerIntermediateBase,
            rightLittleFingerIntermediateBaseModelEntity.transform
        )
        rightLittleFingerIntermediateTipModelEntity.transform = getTransform(
            rightHandAnchor,
            .littleFingerIntermediateTip,
            rightLittleFingerIntermediateTipModelEntity.transform
        )
        rightLittleFingerTipModelEntity.transform = getTransform(
            rightHandAnchor,
            .littleFingerTip,
            rightLittleFingerTipModelEntity.transform
        )
        rightForearmWristModelEntity.transform = getTransform(
            rightHandAnchor,
            .forearmWrist,
            rightForearmWristModelEntity.transform
        )
        rightForearmArmModelEntity.transform = getTransform(
            rightHandAnchor,
            .forearmArm,
            rightForearmArmModelEntity.transform
        )

        struct CodableHandTracking: Codable {
            //Skeleton Joints to Track in View
            let leftWristModelTransform: [[Double]]
            let leftThumbKnuckleModelTransform: [[Double]]
            let leftThumbIntermediateBaseModelTransform: [[Double]]
            let leftThumbIntermediateTipModelTransform: [[Double]]
            let leftThumbTipModelTransform: [[Double]]
            let leftIndexFingerMetacarpalModelTransform: [[Double]]
            let leftIndexFingerKnuckleModelTransform: [[Double]]
            let leftIndexFingerIntermediateBaseModelTransform: [[Double]]
            let leftIndexFingerIntermediateTipModelTransform: [[Double]]
            let leftIndexFingerTipModelTransform: [[Double]]
            let leftMiddleFingerMetacarpalModelTransform: [[Double]]
            let leftMiddleFingerKnuckleModelTransform: [[Double]]
            let leftMiddleFingerIntermediateBaseModelTransform: [[Double]]
            let leftMiddleFingerIntermediateTipModelTransform: [[Double]]
            let leftMiddleFingerTipModelTransform: [[Double]]
            let leftRingFingerMetacarpalModelTransform: [[Double]]
            let leftRingFingerKnuckleModelTransform: [[Double]]
            let leftRingFingerIntermediateBaseModelTransform: [[Double]]
            let leftRingFingerIntermediateTipModelTransform: [[Double]]
            let leftRingFingerTipModelTransform: [[Double]]
            let leftLittleFingerMetacarpalModelTransform: [[Double]]
            let leftLittleFingerKnuckleModelTransform: [[Double]]
            let leftLittleFingerIntermediateBaseModelTransform: [[Double]]
            let leftLittleFingerIntermediateTipModelTransform: [[Double]]
            let leftLittleFingerTipModelTransform: [[Double]]
            let leftForearmWristModelTransform: [[Double]]
            let leftForearmArmModelTransform: [[Double]]

            let rightWristModelTransform: [[Double]]
            let rightThumbKnuckleModelTransform: [[Double]]
            let rightThumbIntermediateBaseModelTransform: [[Double]]
            let rightThumbIntermediateTipModelTransform: [[Double]]
            let rightThumbTipModelTransform: [[Double]]
            let rightIndexFingerMetacarpalModelTransform: [[Double]]
            let rightIndexFingerKnuckleModelTransform: [[Double]]
            let rightIndexFingerIntermediateBaseModelTransform: [[Double]]
            let rightIndexFingerIntermediateTipModelTransform: [[Double]]
            let rightIndexFingerTipModelTransform: [[Double]]
            let rightMiddleFingerMetacarpalModelTransform: [[Double]]
            let rightMiddleFingerKnuckleModelTransform: [[Double]]
            let rightMiddleFingerIntermediateBaseModelTransform: [[Double]]
            let rightMiddleFingerIntermediateTipModelTransform: [[Double]]
            let rightMiddleFingerTipModelTransform: [[Double]]
            let rightRingFingerMetacarpalModelTransform: [[Double]]
            let rightRingFingerKnuckleModelTransform: [[Double]]
            let rightRingFingerIntermediateBaseModelTransform: [[Double]]
            let rightRingFingerIntermediateTipModelTransform: [[Double]]
            let rightRingFingerTipModelTransform: [[Double]]
            let rightLittleFingerMetacarpalModelTransform: [[Double]]
            let rightLittleFingerKnuckleModelTransform: [[Double]]
            let rightLittleFingerIntermediateBaseModelTransform: [[Double]]
            let rightLittleFingerIntermediateTipModelTransform: [[Double]]
            let rightLittleFingerTipModelTransform: [[Double]]
            let rightForearmWristModelTransform: [[Double]]
            let rightForearmArmModelTransform: [[Double]]

            let headPoseTransform: [[Double]]
        }

        do {
            let obj = CodableHandTracking(
                leftWristModelTransform: getCodableTransform(
                    transform: leftWristModelEntity.transform
                ),
                leftThumbKnuckleModelTransform: getCodableTransform(
                    transform: leftThumbKnuckleModelEntity.transform
                ),
                leftThumbIntermediateBaseModelTransform: getCodableTransform(
                    transform: leftThumbIntermediateBaseModelEntity.transform
                ),
                leftThumbIntermediateTipModelTransform: getCodableTransform(
                    transform: leftThumbIntermediateTipModelEntity.transform
                ),
                leftThumbTipModelTransform: getCodableTransform(
                    transform: leftThumbTipModelEntity.transform
                ),
                leftIndexFingerMetacarpalModelTransform: getCodableTransform(
                    transform: leftIndexFingerMetacarpalModelEntity.transform
                ),
                leftIndexFingerKnuckleModelTransform: getCodableTransform(
                    transform: leftIndexFingerKnuckleModelEntity.transform
                ),
                leftIndexFingerIntermediateBaseModelTransform:
                    getCodableTransform(
                        transform: leftIndexFingerIntermediateBaseModelEntity
                            .transform
                    ),
                leftIndexFingerIntermediateTipModelTransform:
                    getCodableTransform(
                        transform: leftIndexFingerIntermediateTipModelEntity
                            .transform
                    ),
                leftIndexFingerTipModelTransform: getCodableTransform(
                    transform: leftIndexFingerTipModelEntity.transform
                ),
                leftMiddleFingerMetacarpalModelTransform: getCodableTransform(
                    transform: leftMiddleFingerMetacarpalModelEntity.transform
                ),
                leftMiddleFingerKnuckleModelTransform: getCodableTransform(
                    transform: leftMiddleFingerKnuckleModelEntity.transform
                ),
                leftMiddleFingerIntermediateBaseModelTransform:
                    getCodableTransform(
                        transform: leftMiddleFingerIntermediateBaseModelEntity
                            .transform
                    ),
                leftMiddleFingerIntermediateTipModelTransform:
                    getCodableTransform(
                        transform: leftMiddleFingerIntermediateTipModelEntity
                            .transform
                    ),
                leftMiddleFingerTipModelTransform: getCodableTransform(
                    transform: leftMiddleFingerTipModelEntity.transform
                ),
                leftRingFingerMetacarpalModelTransform: getCodableTransform(
                    transform: leftRingFingerMetacarpalModelEntity.transform
                ),
                leftRingFingerKnuckleModelTransform: getCodableTransform(
                    transform: leftRingFingerKnuckleModelEntity.transform
                ),
                leftRingFingerIntermediateBaseModelTransform:
                    getCodableTransform(
                        transform: leftRingFingerIntermediateBaseModelEntity
                            .transform
                    ),
                leftRingFingerIntermediateTipModelTransform:
                    getCodableTransform(
                        transform: leftRingFingerIntermediateTipModelEntity
                            .transform
                    ),
                leftRingFingerTipModelTransform: getCodableTransform(
                    transform: leftRingFingerTipModelEntity.transform
                ),
                leftLittleFingerMetacarpalModelTransform: getCodableTransform(
                    transform: leftLittleFingerMetacarpalModelEntity.transform
                ),
                leftLittleFingerKnuckleModelTransform: getCodableTransform(
                    transform: leftLittleFingerKnuckleModelEntity.transform
                ),
                leftLittleFingerIntermediateBaseModelTransform:
                    getCodableTransform(
                        transform: leftLittleFingerIntermediateBaseModelEntity
                            .transform
                    ),
                leftLittleFingerIntermediateTipModelTransform:
                    getCodableTransform(
                        transform: leftLittleFingerIntermediateTipModelEntity
                            .transform
                    ),
                leftLittleFingerTipModelTransform: getCodableTransform(
                    transform: leftLittleFingerTipModelEntity.transform
                ),
                leftForearmWristModelTransform: getCodableTransform(
                    transform: leftForearmWristModelEntity.transform
                ),
                leftForearmArmModelTransform: getCodableTransform(
                    transform: leftForearmArmModelEntity.transform
                ),

                rightWristModelTransform: getCodableTransform(
                    transform: rightWristModelEntity.transform
                ),
                rightThumbKnuckleModelTransform: getCodableTransform(
                    transform: rightThumbKnuckleModelEntity.transform
                ),
                rightThumbIntermediateBaseModelTransform: getCodableTransform(
                    transform: rightThumbIntermediateBaseModelEntity.transform
                ),
                rightThumbIntermediateTipModelTransform: getCodableTransform(
                    transform: rightThumbIntermediateTipModelEntity.transform
                ),
                rightThumbTipModelTransform: getCodableTransform(
                    transform: rightThumbTipModelEntity.transform
                ),
                rightIndexFingerMetacarpalModelTransform: getCodableTransform(
                    transform: rightIndexFingerMetacarpalModelEntity.transform
                ),
                rightIndexFingerKnuckleModelTransform: getCodableTransform(
                    transform: rightIndexFingerKnuckleModelEntity.transform
                ),
                rightIndexFingerIntermediateBaseModelTransform:
                    getCodableTransform(
                        transform: rightIndexFingerIntermediateBaseModelEntity
                            .transform
                    ),
                rightIndexFingerIntermediateTipModelTransform:
                    getCodableTransform(
                        transform: rightIndexFingerIntermediateTipModelEntity
                            .transform
                    ),
                rightIndexFingerTipModelTransform: getCodableTransform(
                    transform: rightIndexFingerTipModelEntity.transform
                ),
                rightMiddleFingerMetacarpalModelTransform: getCodableTransform(
                    transform: rightMiddleFingerMetacarpalModelEntity.transform
                ),
                rightMiddleFingerKnuckleModelTransform: getCodableTransform(
                    transform: rightMiddleFingerKnuckleModelEntity.transform
                ),
                rightMiddleFingerIntermediateBaseModelTransform:
                    getCodableTransform(
                        transform: rightMiddleFingerIntermediateBaseModelEntity
                            .transform
                    ),
                rightMiddleFingerIntermediateTipModelTransform:
                    getCodableTransform(
                        transform: rightMiddleFingerIntermediateTipModelEntity
                            .transform
                    ),
                rightMiddleFingerTipModelTransform: getCodableTransform(
                    transform: rightMiddleFingerTipModelEntity.transform
                ),
                rightRingFingerMetacarpalModelTransform: getCodableTransform(
                    transform: rightRingFingerMetacarpalModelEntity.transform
                ),
                rightRingFingerKnuckleModelTransform: getCodableTransform(
                    transform: rightRingFingerKnuckleModelEntity.transform
                ),
                rightRingFingerIntermediateBaseModelTransform:
                    getCodableTransform(
                        transform: rightRingFingerIntermediateBaseModelEntity
                            .transform
                    ),
                rightRingFingerIntermediateTipModelTransform:
                    getCodableTransform(
                        transform: rightRingFingerIntermediateTipModelEntity
                            .transform
                    ),
                rightRingFingerTipModelTransform: getCodableTransform(
                    transform: rightRingFingerTipModelEntity.transform
                ),
                rightLittleFingerMetacarpalModelTransform: getCodableTransform(
                    transform: rightLittleFingerMetacarpalModelEntity.transform
                ),
                rightLittleFingerKnuckleModelTransform: getCodableTransform(
                    transform: rightLittleFingerKnuckleModelEntity.transform
                ),
                rightLittleFingerIntermediateBaseModelTransform:
                    getCodableTransform(
                        transform: rightLittleFingerIntermediateBaseModelEntity
                            .transform
                    ),
                rightLittleFingerIntermediateTipModelTransform:
                    getCodableTransform(
                        transform: rightLittleFingerIntermediateTipModelEntity
                            .transform
                    ),
                rightLittleFingerTipModelTransform: getCodableTransform(
                    transform: rightLittleFingerTipModelEntity.transform
                ),
                rightForearmWristModelTransform: getCodableTransform(
                    transform: rightForearmWristModelEntity.transform
                ),
                rightForearmArmModelTransform: getCodableTransform(
                    transform: rightForearmArmModelEntity.transform
                ),

                headPoseTransform: getCodableTransform(
                    transform: deviceTransform
                ),

            )
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(obj)
            //            let currentTimestamp = String(format: "%.6f", Date().timeIntervalSince1970)
            let currentTimestamp: TimeInterval = Date().timeIntervalSince1970
            jsonEncoder.outputFormatting = .prettyPrinted

            
            do {
                try jsonData.write(
                    to: URL(
                        fileURLWithPath: Constants.handTrackingFilePath(
                            sessionStartTime: parameters.sessionStartTime,
                            ts: currentTimestamp
                        )
                    )
                )
                numFrames += 1
            }
        } catch {
            logger.error(
                "Could not convert struct to JSON. Error: \(error.localizedDescription)"
            )
        }

        // Swift starts error out with the following message when DispatchQueue is not used.
        // "Publishing changes from within view updates is not allowed, this will cause undefined behavior."
        DispatchQueue.main.async {
            parameters.handTrackingLastTimestamp = CFAbsoluteTimeGetCurrent()
            if self.numFrames % parameters.jsonFPSCalcFreq == 0 {
                parameters.handTrackingDataFPS =
                    Double(parameters.jsonFPSCalcFreq)
                    / (CFAbsoluteTimeGetCurrent() - self.startTime)
                self.startTime = CFAbsoluteTimeGetCurrent()
                logger.info(
                    "Hand Tracking Data FPS: \(parameters.handTrackingDataFPS)"
                )
            }
        }

    }

    func getTransform(
        _ anchor: HandAnchor,
        _ jointName: HandSkeleton.JointName,
        _ beforeTransform: Transform
    ) -> Transform {
        let joint = anchor.handSkeleton?.joint(jointName)
        if (joint?.isTracked) != nil {
            let t = matrix_multiply(
                anchor.originFromAnchorTransform,
                (anchor.handSkeleton?.joint(jointName).anchorFromJointTransform)!
            )
            return Transform(matrix: t)
        }
        return beforeTransform
    }

    func addToContent(_ content: RealityKit.RealityViewContent) {
        // Skeleton Joints to Track in View
        let modelEntities = [
            //Skeleton Joints to Track in View
            leftWristModelEntity,
            leftThumbKnuckleModelEntity,
            leftThumbIntermediateBaseModelEntity,
            leftThumbIntermediateTipModelEntity,
            leftThumbTipModelEntity,
            leftIndexFingerMetacarpalModelEntity,
            leftIndexFingerKnuckleModelEntity,
            leftIndexFingerIntermediateBaseModelEntity,
            leftIndexFingerIntermediateTipModelEntity,
            leftIndexFingerTipModelEntity,
            leftMiddleFingerMetacarpalModelEntity,
            leftMiddleFingerKnuckleModelEntity,
            leftMiddleFingerIntermediateBaseModelEntity,
            leftMiddleFingerIntermediateTipModelEntity,
            leftMiddleFingerTipModelEntity,
            leftRingFingerMetacarpalModelEntity,
            leftRingFingerKnuckleModelEntity,
            leftRingFingerIntermediateBaseModelEntity,
            leftRingFingerIntermediateTipModelEntity,
            leftRingFingerTipModelEntity,
            leftLittleFingerMetacarpalModelEntity,
            leftLittleFingerKnuckleModelEntity,
            leftLittleFingerIntermediateBaseModelEntity,
            leftLittleFingerIntermediateTipModelEntity,
            leftLittleFingerTipModelEntity,
            leftForearmWristModelEntity,
            leftForearmArmModelEntity,

            rightWristModelEntity,
            rightThumbKnuckleModelEntity,
            rightThumbIntermediateBaseModelEntity,
            rightThumbIntermediateTipModelEntity,
            rightThumbTipModelEntity,
            rightIndexFingerMetacarpalModelEntity,
            rightIndexFingerKnuckleModelEntity,
            rightIndexFingerIntermediateBaseModelEntity,
            rightIndexFingerIntermediateTipModelEntity,
            rightIndexFingerTipModelEntity,
            rightMiddleFingerMetacarpalModelEntity,
            rightMiddleFingerKnuckleModelEntity,
            rightMiddleFingerIntermediateBaseModelEntity,
            rightMiddleFingerIntermediateTipModelEntity,
            rightMiddleFingerTipModelEntity,
            rightRingFingerMetacarpalModelEntity,
            rightRingFingerKnuckleModelEntity,
            rightRingFingerIntermediateBaseModelEntity,
            rightRingFingerIntermediateTipModelEntity,
            rightRingFingerTipModelEntity,
            rightLittleFingerMetacarpalModelEntity,
            rightLittleFingerKnuckleModelEntity,
            rightLittleFingerIntermediateBaseModelEntity,
            rightLittleFingerIntermediateTipModelEntity,
            rightLittleFingerTipModelEntity,
            rightForearmWristModelEntity,
            rightForearmArmModelEntity,
        ]

        modelEntities.forEach { content.add($0) }
    }

}
