import { Navigate, Route, Routes } from "react-router-dom";
import AppLayout from "./components/AppLayout.jsx";
import DiagnosticExplorer from "./pages/DiagnosticExplorer.jsx";
import ExecutiveOverview from "./pages/ExecutiveOverview.jsx";
import MetricDictionary from "./pages/MetricDictionary.jsx";

export default function App() {
  return (
    <Routes>
      <Route element={<AppLayout />}>
        <Route index element={<Navigate to="/overview" replace />} />
        <Route path="overview" element={<ExecutiveOverview />} />
        <Route path="diagnostics" element={<DiagnosticExplorer />} />
        <Route path="metrics" element={<MetricDictionary />} />
        <Route path="*" element={<Navigate to="/overview" replace />} />
      </Route>
    </Routes>
  );
}
