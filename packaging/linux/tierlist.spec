Name:           tierlist
Version:        1.0.0
Release:        1%{?dist}
Summary:        S–F tier list app for ranking images
License:        MIT
URL:            https://localhost
Source0:        %{name}-%{version}-linux-amd64.tar.gz
BuildArch:      x86_64

%description
Upload images and drag them into S, A, B, C, D, and F tiers.

%prep
%setup -c -n %{name}-%{version}

%build

%install
install -Dm755 tierlist %{buildroot}%{_bindir}/tierlist
install -Dm644 tierlist.desktop %{buildroot}%{_datadir}/applications/tierlist.desktop
install -Dm644 README.md %{buildroot}%{_pkgdocdir}/README.md

%files
%{_bindir}/tierlist
%{_datadir}/applications/tierlist.desktop
%{_pkgdocdir}/README.md

%changelog
* Sat Sep 05 2026 Aahil <aahil@localhost> - 1.0.0-1
- Initial Linux release
