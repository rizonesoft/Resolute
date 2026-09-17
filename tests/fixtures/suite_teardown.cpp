// Suite-level teardown for the fixture store. D00 T02 §2.
//
// Each fixture removes its own key and tree, which is what makes cleanup
// survive a failure. Nothing removed the ROOTS they live under, so a run left
// an empty HKCU\Software\ResoluteTestFixtures behind: no data, but a key on a
// user's machine that this suite created and never took back.
//
// The checkpoint requires the root absent after a run, and it is right to: a
// test suite that leaves a registry key behind has not finished cleaning up,
// and "it was empty" is the argument every leftover key has.
//
// Catch2 runs this after the last test, whether the run passed or failed.

#include <catch2/reporters/catch_reporter_event_listener.hpp>
#include <catch2/reporters/catch_reporter_registrars.hpp>

#include "fixtures.h"

namespace {

class FixtureStoreTeardown : public Catch::EventListenerBase {
public:
    using Catch::EventListenerBase::EventListenerBase;

    // RAII cleans up a throw. It does not survive a process death: std::abort
    // and a crash run no destructors, proven by aborting mid-test and finding
    // the key and the tree still there. Sweeping here means a previous run's
    // crash cannot outlive this one.
    void testRunStarting(const Catch::TestRunInfo&) override {
        resolute::fixtures::RegistryFixture::SweepRoot();
        resolute::fixtures::FileTreeFixture::SweepStoreRoot();
    }

    void testRunEnded(const Catch::TestRunStats&) override {
        // Both are "if empty" by construction: a root that still holds a
        // fixture is left alone, so a bug here cannot delete live state out
        // from under anything.
        resolute::fixtures::RegistryFixture::RemoveRootIfEmpty();
        resolute::fixtures::FileTreeFixture::RemoveStoreRootIfEmpty();
    }
};

} // namespace

// The static registrar is Catch2's, not ours: CATCH_REGISTER_LISTENER is the
// documented way to register a listener and it declares a namespace-scope
// object whose construction can in principle throw. There is no narrower
// alternative that still registers a listener, and the only other option is
// not having suite-level teardown at all, which is what this file exists for.
// Suppressed at this one line rather than by raising the tidy baseline, so the
// exception stays attached to its reason. D00 T02 §2.
//
// NOLINTNEXTLINE(bugprone-throwing-static-initialization)
CATCH_REGISTER_LISTENER(FixtureStoreTeardown)
